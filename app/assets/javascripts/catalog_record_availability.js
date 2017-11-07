// JavaScript functions for individual catalog records.
// Loaded by `app/views/catalog/show.html.erb`.
$(document).ready(
  function(){
    var bib_id = getBibId();
    addOcraLink(bib_id);
    addVirtualShelfLinks(bib_id);
    var api_url = availabilityService + bib_id + "/?callback=?";
    var limit = getUrlParameter("limit");
    if (limit == "false") {
      api_url = api_url + "&limit=false"
    }
    $.getJSON(api_url, addAvailability);

    if (location.search.indexOf("nearby") > -1) {
      loadNearbyItems(false);
    }
  }
);


function getBibId() {
  /* Pulls bib_id from DOM, called on doc.ready */
  bib_id_div_name = $( "div[id^='doc_']" )[0].id;
  bib_id_start = bib_id_div_name.search( '_' ) + 1;
  bib_id = bib_id_div_name.substring( bib_id_start );
  return bib_id;
}


function getTitle() {
  return $('h3[itemprop="name"]').text();
}


function getFormat() {
  return $("dd.blacklight-format").text().trim();
}


function processItems(availabilityResponse) {
  var out = []
  $.each(availabilityResponse.items, function( index, item ) {
    var loc = item['location'].toLowerCase();
    out.push(item);
  });
  var rsp = availabilityResponse;
  return rsp;
}


function hasItems(availabilityResponse) {
  return (availabilityResponse.items.length > 0);
}


function addAvailability(availabilityResponse) {
  var title = getTitle();
  var bib = getBibId();
  var format = getFormat();
  //check for request button
  addRequestButton(availabilityResponse)
  //do realtime holdings
  context = availabilityResponse;
  context['book_title'] = title;
  context['online_resource'] = $("#online_resources").length == 1
  if (hasItems(availabilityResponse)) {
    _.each(context['items'], function(item) {

      // add title to map link.
      item['map'] = item['map'] + '&title=' + title;

      // add bookplate information
      // item_info() is defined in _show_default.html.erb
      var bookplate = item_info(item['barcode'])
      if (bookplate != null) {
        item['bookplate_url'] = bookplate.url;
        item['bookplate_display'] = bookplate.display;
      }

      //add easyScan link & item request
      if (canScanItem(item['location'], format)) {
        item['scan'] = easyScanFullLink(item['scan'], bib, title);
        item['item_request_url'] = itemRequestFullLink(item['barcode'], bib);
      } else {
        item['scan'] = null;
        item['item_request_url'] = null;
      }

      // add jcb aeon link if necessary
      if ( item['location'].slice(0, 3) == "JCB" ) {
        console.log( 'jcb title, ```' + title + '```' )
        item['jcb_url'] = jcbRequestFullLink( bib, title, getAuthor(), getPublisher(), item['callnumber'] );
      }

      // add hay aeon link if necessary
      if ( item['location'].slice(0, 3) == "HAY" ) {
        console.log( '- hay title, ```' + title + '```' )
        if ( isValidHayAeonLocation(item['location']) == true ) {
          item['hay_aeon_url'] = hayAeonFullLink( bib, title, getAuthor(), getPublisher(), item['callnumber'], item['location'] );
        }
      }

    });
  }

  if (context['has_more'] == true) {
    context['more_link'] = window.location.href + '?limit=false';
  }
  //turning off for now.
  context['show_ezb_button'] = false;
  if (availabilityResponse.requestable) {
    context['request_link'] = requestLink();
  };
  html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
  $("#availability").append(html);
}


function getAuthor() {
  // for JCB link
  // slicing occurs in application.js
  var elements = $('h5[class="title-subheading"]');
  if (elements.length == 0) {
    return "";
  }
  var author = elements[0].textContent;
  console.log( 'author, ```' + author + '```' );
  return author;
}


function getPublisher() {
  // for JCB link
  // don't think we need elegant slicing for publisher
  var elements = $('h5[class="title-subheading"]');
  if (elements.length < 2) {
    return "";
  }
  var publisher = elements[1].textContent.slice( 0, 100 );
  return publisher;
}


function requestLink() {
  var bib = getBibId();
  return 'https://josiah.brown.edu/search~S7?/.' + bib + '/.' + bib + '/%2C1%2C1%2CB/request~' + bib;
}


function addRequestButton(availabilityResponse) {
  //ugly Josiah request url.
  //https://josiah.brown.edu/search~S7?/.b2305331/.b2305331/1%2C1%2C1%2CB/request~b2305331
  if (availabilityResponse.requestable) {
    var bib = getBibId();
    var url = 'https://josiah.brown.edu/search~S7?/.' + bib + '/.' + bib + '/%2C1%2C1%2CB/request~' + bib;
    //$('#sidebar ul.nav').prepend('<li><a href=\"' + url + '\">Request this</a></li>');
  };
}


function getUrlParameter(sParam) {
  var sPageURL = window.location.search.substring(1);
  var sURLVariables = sPageURL.split('&');
  for (var i = 0; i < sURLVariables.length; i++) {
    var sParameterName = sURLVariables[i].split('=');
    if (sParameterName[0] == sParam) {
      return sParameterName[1];
    }
  }
}


// =============================================
//
// Virtual Shelf functions
//
// =============================================
function browseShelfUri(id, block, norm) {
  // josiahRootUrl is defined in shared/_header_navbar.html.erb
  url = josiahRootUrl + "api/items/nearby?id=" + id;
  if (block) {
    url += "&block=" + block;
  }
  if (norm) {
    url += "&normalized=" + norm;
  }
  return url;
}


function browseStackUri(id) {
  // josiahRootUrl is defined in shared/_header_navbar.html.erb
  return josiahRootUrl + "browse/" + id;
}


function scrollToBottomOfPage() {
  // scroll to bottom of the page
  // http://stackoverflow.com/a/10503637/446681
  $("html, body").animate({ scrollTop: $(document).height() }, 1000);
}


function loadNearbyItems(scroll) {
  var id = getBibId();
  var url = browseShelfUri(id, null, null);
  $.getJSON(url, function(data) {
    if (data.docs.length == 0) {
      $("#also-on-shelf").removeClass("hidden");
      $("#also-on-shelf-none").removeClass("hidden");
    } else {
      addDebugInfoToDocs(data.docs);
      var i;
      for(i = 0; i < data.docs.length; i++) {
        data.docs[i].shelfrank = data.docs[i].id == id ? 50 : 15;
      }
      // Make a global object available for use as the user loads more data.
      // I don't like that I am referencing the internals of the stackviewObject
      // but this would do for now while I figure out a better way to load
      // data on demand.
      if (window.theStackViewObject == undefined) {
        window.theStackViewObject = $('#basic-stack').stackView({data: data, query: "test book", ribbon: ""}).data().stackviewObject;
      } else {
        var i;
        for(i = 0; i < data.docs.length; i++) {
          window.theStackViewObject.add(i, data.docs[i]);
        }
        var numItemsAdded = data.docs.length;
        for(i = 0; i < numItemsAdded; i++) {
          window.theStackViewObject.remove(numItemsAdded);
        }
      }
      updateNearbyBounds(data.docs, true, true);
      $("#also-on-shelf").removeClass("hidden");
      $(".upstream").on("click", function() { loadPrevNearbyItems(); });
      $(".downstream").on("click", function() { loadNextNearbyItems(); });
      clearResetButton();
    }

    if (scroll) {
      scrollToBottomOfPage();
    }
  });
}


function loadPrevNearbyItems() {
  var id = $("#firstBook").text();
  var norm = $("#firstBookNorm").text();
  var url = browseShelfUri(id, "prev", norm);
  $.getJSON(url, function(data) {
    addDebugInfoToDocs(data.docs);
    highlightCurrent(data.docs);
    var lastIndex = window.theStackViewObject.options.data.docs.length - 1;
    var i;
    for(i = 0; i < data.docs.length; i++) {
      window.theStackViewObject.remove(lastIndex);
      window.theStackViewObject.add(i, data.docs[i]);
    }
    showResetButton();
    updateNearbyBounds(data.docs, true, true);
  });
}


function loadNextNearbyItems() {
  var id = $("#lastBook").text();
  var norm = $("#lastBookNorm").text();
  var url = browseShelfUri(id, "next", norm);
  $.getJSON(url, function(data) {
    addDebugInfoToDocs(data.docs);
    highlightCurrent(data.docs);
    var i;
    for(i = 0; i < data.docs.length; i++) {
      window.theStackViewObject.remove(0);
      window.theStackViewObject.add(data.docs[i]);
    }
    showResetButton();
    updateNearbyBounds(data.docs, true, true);
  });
}


// Save the Id and normalized call number at the top and/or bottom
// of the stack. We use these values as our starting point when the
// users wants to continue fetching records.
function updateNearbyBounds(docs, prev, next) {
  if (docs.length == 0) {
    if (prev) {
      $("#firstBook").text("");
      $("#firstBookNorm").text("");
    }
    if (next) {
      $("#lastBook").text("");
      $("#lastBookNorm").text("");
    }
  } else {
    if (prev) {
      $("#firstBook").text(docs[0].id);
      $("#firstBookNorm").text(docs[0].normalized);
    }
    if (next) {
      $("#lastBook").text(docs[docs.length-1].id);
      $("#lastBookNorm").text(docs[docs.length-1].normalized);
    }
  }
}


function highlightCurrent(docs) {
  var currentId = getBibId();
  var i;
  for(i = 0; i < docs.length; i++) {
    if (docs[i].id == currentId) {
      docs[i].shelfrank = 50;
      break;
    }
  }
}


function addDebugInfoToDocs(docs) {
  if (location.search.indexOf("verbose") == -1) {
    return;
  }
  var i;
  for(i = 0; i < docs.length; i++) {
    doc = docs[i];
    doc.title = doc.title + "<br/>" + doc.id + ": " + doc.callnumbers.toString();
  }
}


function showResetButton() {
  var href = '<a onClick="loadNearbyItems(false); return false;" ' +
    'href="#" title="Show me the inital stack of books">reset</a>';
  var html = "<span>" + href + "</span>";
  $(".num-found").html(html);
}


function clearResetButton() {
  var html = '<span>&nbsp;</span>';
  $(".num-found").html(html);
}


function addOcraLink(bib_id) {
  var ocraUrl = "https://library.brown.edu/reserves/cr/ocrify/?bibnum=" + bib_id;
  var helpInfo = "Staff and Teaching Assistants can reserve this item in OCRA for courses they teach.";
  var link = '<li><a href="' + ocraUrl + '" title="' + helpInfo + '" target="_blank">Add to OCRA</a>';
  $("div.panel-body>ul.nav").append(link);
}


function addVirtualShelfLinks(bib_id) {
  // Add "More Like This" option to tools section
  var link1 = '<li><a onclick="loadNearbyItems(true); return false;" href="#">More Like This</a>';
  $("div.panel-body>ul.nav").append(link1);

  // Add "Browse the stacks" option to tools section
  var link2 = '<li><a href="' + browseStackUri(bib_id) + '" target="_blank">Browse the Stacks</a>';
  $("div.panel-body>ul.nav").append(link2);
}

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


function getItemById(id) {
  var i;
  for(i = 0; i < itemsData.length; i++) {
    if (itemsData[i].id == id) {
      return itemsData[i];
    }
  }
  return null;
}

function getItemByBarcode(barcode) {
  var i;
  for(i = 0; i < itemsData.length; i++) {
    if (itemsData[i].barcode == barcode) {
      return itemsData[i];
    }
  }
  return null;
}


function getBibId() {
  return bibData.id;
}


function getTitle() {
  return bibData.title;
}


function getFormat() {
  return bibData.format;
}


function getAuthor() {
  return bibData.author;
}


function getPublisher() {
  bibData.publisher;
}


function addAvailability(availabilityResponse) {

  // Realtime status of items (and other item specific information)
  _.each(availabilityResponse.items, function(avItem) {
    updateItemInfo(avItem);
  });

  if (availabilityResponse.has_more == true) {
    $("#show_more_items").removeClass("hidden");
  }

  if (availabilityResponse.requestable) {
    $(".request-this-link").removeClass("hidden");
  };
}

// TODO: why do these show online and aval in prod. (which is correct)
// https://search.library.brown.edu/catalog/b8085136
// https://search.library.brown.edu/catalog/b5850361

// Updates item information (already on the page) with the
// extra information that we got from the Availability service.
function updateItemInfo(avItem) {
  var item, barcode, itemRow;

  barcode = avItem['barcode'];
  item = getItemByBarcode(barcode);
  if (item == null) {
    showError("ERROR: barcode " + barcode + " not found in MARC item data");
    return;
  }

  if (item.call_number != avItem['callnumber']) {
    showError("WARN: call number mismatch for barcode " + barcode + ": " + item.call_number  + " vs " + avItem['callnumber']);
  }

  itemRow = $("#item_" + item.id);
  updateItemMap(itemRow, avItem);
  updateItemStatus(itemRow, avItem);
  updateItemScanStatus(itemRow, avItem, barcode);
  updateItemAeonLinks(itemRow, avItem);
}


function updateItemMap(row, avItem) {
  var floor, aisle, mapText, mapUrl, html;
  if (avItem['shelf'] && avItem['shelf']['floor'] && avItem['shelf']['aisle']) {
    floor = avItem['shelf']['floor'];
    aisle = avItem['shelf']['aisle'];
    mapText = "Level " + floor + ", Aisle " + aisle;
    if (avItem['map']) {
      mapUrl = avItem['map'] + '&title=' + getTitle();
      html = "-- <a href=" + mapUrl + ">" + mapText + "</a>";
    } else {
      html = "-- mapText";
    }
    row.find(".location_map").html(html);
  }
}


function updateItemStatus(row, avItem) {
  if (avItem['status']) {
    row.find(".status").html(avItem['status']);
  }
}


function updateItemScanStatus(row, avItem, barcode) {
  var scanLink, itemLink, html;
  // Birkin's original code
  //add easyScan link & item request
  // if (canScanItem(item['location'], format)) {
  //   item['scan'] = easyScanFullLink(item['scan'], bib, title);
  //   item['item_request_url'] = itemRequestFullLink(item['barcode'], bib);
  // } else {
  //   item['scan'] = null;
  //   item['item_request_url'] = null;
  // }
  if (canScanItem(avItem['location'], bibData.format)) {
    scanLink = '<a href="' + easyScanFullLink(avItem['scan'], bibData.id, bibData.title) + '">scan</a>';
    itemLink = '<a href="' + itemRequestFullLink(barcode, bibData.id) + '">item</a>';
    html = scanLink + " | " + itemLink;
    row.find(".scan").html(html);
  }
}


function updateItemAeonLinks(row, avItem) {
  var location, url, html;
  // Birkin's original code
  // // add jcb aeon link if necessary
  // if ( item['location'].slice(0, 3) == "JCB" ) {
  //   console.log( 'jcb title, ```' + title + '```' )
  //   item['jcb_url'] = jcbRequestFullLink( bib, title, getAuthor(), getPublisher(), item['callnumber'] );
  // }
  //
  // // add hay aeon link if necessary
  // if ( item['location'].slice(0, 3) == "HAY" ) {
  //   console.log( '- hay title, ```' + title + '```' )
  //   if ( isValidHayAeonLocation(item['location']) == true ) {
  //     item['hay_aeon_url'] = hayAeonFullLink( bib, title, getAuthor(), getPublisher(), item['callnumber'], item['location'] );
  //   }
  // }

  location = (avItem['location'] || "").slice(0, 3);

  // JCB Aeon link
  if (location == "JCB") {
    url = jcbRequestFullLink(bibData.id, bibData.title, bibData.author, bibData.publisher, avItem['callnumber']);
    html = '<a href="' + url + '">request-access</a>';
    row.find(".jcb_url").html(html);
  }

  // Hay Aeon link
  if (location == "HAY") {
    if (isValidHayAeonLocation(avItem['location']) == true) {
      // Birkin: This version handles author/publisher better because it gets the
      // information from the bibData object rather than guessing from HTML element.
      // See for example http://localhost:3000/catalog/b3326323 (previously the code
      // was using the publisher as the author because there is no author.)
      url = hayAeonFullLink(bibData.id, bibData.title, bibData.author, bibData.publisher, avItem['callnumber'], avItem['location']);
      html = '<a href="' + url + '">request-access</a>';
      row.find(".hay_aeon_url").html(html);
    }
  }
}


function showError(message) {
  $("#errorMsg").removeClass("hidden");
  $("#errorMsg").append("<p>" + message + "</p>");
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

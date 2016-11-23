// JavaScript functions for individual catalog records.
// Loaded by `app/views/catalog/show.html.erb`.
$(document).ready(
  function(){

    // Add Virtual Shelf option to tools section
    link = '<li><a onclick="loadNearbyItems(); return false;" href="#">Virtual Shelf</a>';
    $("div.panel-body>ul.nav").append(link);

    var bib_id = getBibId();
    var api_url = availabilityService + bib_id + "/?callback=?";
    var limit = getUrlParameter("limit");
    if (limit == "false") {
      api_url = api_url + "&limit=false"
    }
    $.getJSON(api_url, addAvailability);

    if (location.search.indexOf("nearby") > -1) {
      findNearbyItems(bib_id, false);
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


function browseShelfUri(id) {
  // josiahRootUrl is defined in shared/_header_navbar.html.erb
  return josiahRootUrl + "api/items/nearby2?id=" + id;
}


function callnumbers_text(callnumbers) {
  if (!callnumbers) {
    return "";
  }
  var text = " (";
  var count = count = callnumbers.length;
  var i;
  for(i=0; i < count; i++) {
    text += callnumbers[i];
    text += (i < (count-1)) ? ", " : "";
  }
  text += ")";
  return text;
}


function loadNearbyItems() {
  id = getBibId();
  renderStackView(id, true);
}


function renderStackView(id, scrollPage) {
  url = browseShelfUri(id)
  $('#basic-stack').stackView({url: url, query: "test book", ribbon: ""});

  if (scrollPage) {
    // scroll to bottom of the page
    // http://stackoverflow.com/a/10503637/446681
    $("html, body").animate({ scrollTop: $(document).height() }, 1000);
  }
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


function getUrlParameter(sParam)
{
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++)
    {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam)
        {
            return sParameterName[1];
        }
    }
}

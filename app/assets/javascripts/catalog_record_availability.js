/*
- Displays availability status of all items for given bib.
  - Grabs bib_id from dom.
  - Hits availability api.
  - Builds html & inserts it into dom.
- Loaded by `app/views/catalog/show.html.erb`.
*/

$(document).ready(
  function(){
    var bib_id = getBibId();
    var api_url = availabilityService + bib_id + "/?callback=?";
    var limit = getUrlParameter("limit");
    if (limit == "false") {
      api_url = api_url + "&limit=false"
    }
    $.getJSON(api_url, addAvailability);
  }
);

function getBibId() {
  /* Pulls bib_id from DOM.
   * Called on doc.ready */
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
  var callnumber = null;
  //check for request button
  addRequestButton(availabilityResponse)
  //do realtime holdings
  context = availabilityResponse;
  context['book_title'] = title;
  if (hasItems(availabilityResponse)) {
    _.each(context['items'], function(item) {

      if ((callnumber == null) && (item.callnumber != null)) {
        // For now, pick the first call number only.
        // This might be OK long term since very likely
        // they will all have the same class/subclass.
        callnumber = item.callnumber;
      }

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
  //context['openurl'] = openurl
  html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
  $("#availability").append(html);

  if (location.search.indexOf("nearby") > -1) {
    if (callnumber != null) {
      findNearbyItems(callnumber);
    }
  }
}

function browseShelveUri(callnumber) {
  // josiahRootUrl is defined in shared/_header_navbar.html.erb
  return josiahRootUrl + "api/items/nearby?per_page=100&callnumber=" + callnumber;
}

function findNearbyItems(callnumber) {
  $.ajax({
      type: "GET",
      url: browseShelveUri(callnumber),
      success: function(data) {
        var the_div = $("#nearby_div");
        $(the_div).removeClass("hidden");
        $(the_div).append("<p>(items near call number " + callnumber + ")</p>");
        $.each(data, function(i, bib){
          var i, callnumbers, callnumber_count;
          if (bib) {
            link = '<a href="' + josiahRootUrl + 'catalog/' + bib.id + '?nearby">' + bib.title_display + '</a>';
            author = bib.author_display ? (" by " + bib.author_display) : "";
            callnumbers = "";
            if(bib.callnumber_t) {
              callnumbers = " (";
              callnumber_count = bib.callnumber_t.length;
              for(i=0; i < callnumber_count; i++) {
                callnumbers += bib.callnumber_t[i];
                callnumbers += (i < (callnumber_count-1)) ? ", " : "";
              }
              callnumbers += ")";
            }
            html = "<p>" + link + author + callnumbers + "</p>";
            $(the_div).append(html);
          };
        });
      }
  });
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

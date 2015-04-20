/*
- Displays availability status of all items for given bib.
  - Grabs bib_id from dom.
  - Hits availability api.
  - Builds html & inserts it into dom.
- Loaded by `app/views/catalog/show.html.erb`.
*/

var locateLocations = [
  'rock',
]
var locatorViewURL = 'https://apps.library.brown.edu/booklocator/'
var locatorDataURL = 'https://apps.library.brown.edu/booklocator/data/'

$(document).ready(
  function(){
    bib_id = getBibId();
    api_url = availabilityService + bib_id + "/?callback=?";
    $.getJSON( api_url, addAvailability );
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
  return $('h3[itemprop="name"]').text();;
}

function processItems(availabilityResponse) {
  var out = []
  $.each(availabilityResponse.items, function( index, item ) {
    var loc = item['location'].toLowerCase();
    item['locate'] = false;
    if (locateLocations.indexOf(loc) > -1) {
      item['locate'] = true;
      var locaterParams = {
        title: getTitle(),
        call: item['callnumber'], 
        loc: item['location'].toLowerCase()
      }
      //item['location'] = getLocation(item);
      item['item_id'] = "item" + index;
      addLocation(item, item['item_id'])
      item['locate_map_url'] =  locatorViewURL + "?" + $.param(locaterParams);
    };
    out.push(item);
  });
  var rsp = availabilityResponse;
  rsp['items'] = out;
  return rsp;
}

function addAvailability(availabilityResponse) {
  context = processItems(availabilityResponse);
  //console.debug(context);
  //turning off for now.
  context['show_ezb_button'] = false;
  //context['openurl'] = openurl
  html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
  $("#availability").append(html);
  //do book locator
  //locate(availabilityResponse['items']);
  //doLocate();
}

function doLocate() {
  $('.locate-item').each(function( index, item) {
    console.debug(item);
  });
}

function locate(items) {
    console.log(items);
    //postLocator(items);
    $.ajax({
        type: "POST",
        url: 'http://localhost:5000/data/',
        //dataType: 'json',
        //contentType: "application/json",
        data: JSON.stringify(items),
        success: function (data) {
            console.log(data);
            $('.holdings-wrapper').append("<h1>" + data['items'][0]['floor'] + "</h1>");
        }
    })
}

function addLocation(item, index) {
  $.getJSON( locatorDataURL, {
    loc: item.location.replace(' ', '-'),
    call: item.callnumber
  })
  .done(function( data ) {
      $.each( data, function( i, item ) {
        if (item !== null) {
          $('#' + index + ' span.locate-item a').text(
            "Level " + item.floor + ", Aisle " + item.aisle
          );
        }
      });
  });
}

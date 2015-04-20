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
      };
      item['item_id'] = "item" + index;
      item['locate_map_url'] =  locatorViewURL + "?" + $.param(locaterParams);
    };
    out.push(item);
  });
  var rsp = availabilityResponse;
  return rsp;
}

function addAvailability(availabilityResponse) {
  context = processItems(availabilityResponse[0]);
  //console.debug(context);
  //turning off for now.
  context['show_ezb_button'] = false;
  //context['openurl'] = openurl
  html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
  $("#availability").append(html);
}
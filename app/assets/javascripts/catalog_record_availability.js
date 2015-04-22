/*
- Displays availability status of all items for given bib.
  - Grabs bib_id from dom.
  - Hits availability api.
  - Builds html & inserts it into dom.
- Loaded by `app/views/catalog/show.html.erb`.
*/

$(document).ready(
  function(){
    bib_id = getBibId();
    api_url = availabilityService + bib_id + "/?callback=?";
    $.getJSON( api_url, addAvailability );
    $('.holdings-wrapper').on('click', '.stack-map-link', function(e) {
      //do something
      console.log('here');
    });
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

function processItems(availabilityResponse) {
  var out = []
  $.each(availabilityResponse.items, function( index, item ) {
    var loc = item['location'].toLowerCase();
    out.push(item);
  });
  var rsp = availabilityResponse;
  return rsp;
}

function addAvailability(availabilityResponse) {
  context = processItems(availabilityResponse);
  context['book_title'] = getTitle();
  context['items'] = _.each(context['items'], function(item) {item['map'] = item['map'] + '&title=' + getTitle()});
  //console.debug(context);
  //turning off for now.
  context['show_ezb_button'] = false;
  //context['openurl'] = openurl
  html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
  $("#availability").append(html);
}
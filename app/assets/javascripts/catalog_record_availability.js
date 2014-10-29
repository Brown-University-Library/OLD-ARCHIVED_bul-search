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
    api_url = availService + bib_id + "/?callback=?";
    $.getJSON( api_url, determine_ezb_availability );
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

function determine_ezb_availability( json_output ) {
  /* Determines whether easyBorrow button should display.
   * Called on doc.ready */
  var show_ezb_button = false; var openurl = null;
  if (json_output['items'].length > 0 ) {  //check for items before updating HTML.
    var available_item = _.find(  // _.find() stops processing on first find
      json_output['items'],
      function( item ) {
        if ( item['is_available'] == true ){ return item; } } );
    if ( ! available_item ) {
      show_ezb_button = true;
      openurl = grab_openurl();
    }
    build_html( json_output, show_ezb_button, openurl );
  }
}

function grab_openurl() {
  /* Grabs and returns item's openurl from openurl-api.
   * Called by determine_ezb_availability() */
  var openurl = "init";
  current_url = location.href;
  $.ajaxSetup( {async: false} );  // otherwise "init" would immediately be returned while $.get makes it's request asynchronously
  $.get( current_url + "/ourl", function( data ) {
    openurl = 'https://library.brown.edu/easyarticle/borrow/?' + data['ourl'];
    } );
  return openurl;
}

function build_html( json_output, show_ezb_button, openurl ) {
  /* Calls template for html, and updates DOM.
   * Called by determine_ezb_availability() */
  context = json_output;
  context['show_ezb_button'] = show_ezb_button;
  context['openurl'] = openurl
  html = HandlebarsTemplates['catalog/ctlg_rcrd_avlblty'](context);
  $("#availability").append( html );
}

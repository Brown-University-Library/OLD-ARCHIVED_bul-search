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
    api_url = "http://library.brown.edu/services/availability/id/" + bib_id + "/?callback=?";
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
  /* Grabs and returns item's openurl created by blacklight from solr's marcxml.
   * Called by determine_ezb_availability() */
  // return "https://library.brown.edu/easyarticle/borrow/?ctx_ver=Z39.88-2004&amp;amp;rft_val_fmt=info:ofi/fmt:kev:mtx:book&amp;amp;rfr_id=info:sid/blacklight.rubyforge.org:generator&amp;amp;rft.genre=book&amp;amp;rft.btitle=Beat Zen, square Zen, and Zen. &amp;amp;rft.title=Beat Zen, square Zen, and Zen. &amp;amp;rft.au=Watts, Alan,&amp;amp;rft.date=[c1959]&amp;amp;rft.place=[San Francisco]&amp;amp;rft.pub=City Lights Books&amp;amp;rft.edition=&amp;amp;rft.isbn=";
  openurl_param = $(".Z3988")[0].title;
  openurl = 'https://library.brown.edu/easyarticle/borrow/?' + openurl_param;
  //console.log( 'openurl, ' + openurl );
  return openurl;
}

function build_html( json_output, show_ezb_button, openurl ) {
  /* Calls template for html, and updates DOM.
   * Called by determine_ezb_availability() */
  //console.log( 'json_output, ' + JSON.stringify(json_output, undefined, 2) );
  //console.log( 'show_ezb_button, ' + show_ezb_button );
  context = json_output;
  context['show_ezb_button'] = show_ezb_button;
  context['openurl'] = openurl
  html = HandlebarsTemplates['catalog/ctlg_rcrd_avlblty'](context);
  $("#availability").append( html );
}

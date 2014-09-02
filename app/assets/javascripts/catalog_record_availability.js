/*
Loaded by `app/views/catalog/show.html.erb`.
- Grabs bib_id from dom.
- Hits availability api.
- Builds html & inserts it into dom.
*/

var bib_id = null;
var all_items_html = '';

$(document).ready(
  function(){
    bib_id = getBibId();
    api_url = "http://library.brown.edu/services/availability/id/" + bib_id + "/?callback=?";
    $.getJSON( api_url, addStatus );
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

function addStatus( json_output ) {
  /* Calls html builders & updates DOM.
   * Called on doc.ready */
  // console.log( "json output..." );
  // console.log( json_output );
  if (json_output['items'].length > 0 ) {  //check for items before adding HTML.
    context = json_output;
    html = HandlebarsTemplates['catalog/ctlg_rcrd_avlblty'](context);
    $("#availability").append( html );
  };
}

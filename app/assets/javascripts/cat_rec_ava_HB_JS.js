/*
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
  //check for items before adding HTML.
  alert( "hi" );
  if (json_output['items'].length > 0 ) {
    // header_html = buildHeaderHtml();
    //josiah_link_html = buildJosiahLinkHtml();
    // json_output.items.forEach( makeItemHtml );
    context = {}
    html = HandlebarsTemplates['catalog/cat_rec_ava_HB_TP'](context);
    $("#availability").append( html );
  };
}

// function addStatus( json_output ) {
//   /* Calls html builders & updates DOM.
//    * Called on doc.ready */
//   //check for items before adding HTML.
//   if (json_output['items'].length > 0 ) {
//     header_html = buildHeaderHtml();
//     //josiah_link_html = buildJosiahLinkHtml();
//     json_output.items.forEach( makeItemHtml );
//     html = header_html + all_items_html + '</div>';
//     // alert( html );
//     $("#availability").append( html );
//   };
// }

// function buildHeaderHtml() {
//   /* Builds initial copy info div html.
//    * Called by addStatus() */
//   header_html = [
//     '<div id="availability_manual">',
//       '<hr/>',
//       '<h5 itemprop="copies">Copy Information</h5>'
//   ].join('\n');
//   return header_html;
// }

// function buildJosiahLinkHtml() {
//   /* Builds josiah link html.
//    * Called by addStatus() */
//   josiah_link_html = [
//     '<dl class="dl-horizontal  dl-invert">',
//       '<dt class="blacklight-josiah_link]">Josiah link:</dt>',
//       '<dd class="blacklight-josiah_link">',
//         '<a href="https://josiah.brown.edu/record=' + bib_id + '">', 'https://josiah.brown.edu/record=' + bib_id, '</a>',
//       '</dd>',
//     '</dl>'
//     ].join('\n');
//   return josiah_link_html;
// }

// function makeItemHtml( item ) {
//   /* Builds single item html.
//    * Called by addStatus() iteration */
//   item_html = [
//     '<dl class="dl-horizontal  dl-invert">',
//       '<dt class="blacklight-callnumber_display">Call Number:</dt>',
//       '<dd class="blacklight-callnumber_display">' + item.callnumber + '</dd>',
//       '<dt class="blacklight-location_display">Location:</dt>',
//       '<dd class="blacklight-location_display">' + item.location + '</dd>',
//       '<dt class="blacklight-availability">Availability:</dt>',
//       '<dd class="blacklight-availability">' + item.availability + '</dd>',
//     '</dl>'
//   ].join('\n');
//   all_items_html = all_items_html + item_html;
// }

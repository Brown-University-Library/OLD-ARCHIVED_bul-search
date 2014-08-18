/*
- Grabs item divs, and for each item...
  - Gets bib_id
  - Hits availability api.
  - Determines summary availability.
  - Builds html & inserts it into dom.
*/

$(document).on(  // $(document).ready... is problematic, see <http://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbolinks>
  "page:change",
  function() {
    grabItemDivs();
  }
);

function grabItemDivs() {
  /* Triggers ajax call for every item-div.
   * Called on doc.on() */
  the_docs = $( ".document" );
  for (var i = 0; i < the_docs.length; i++) {
    the_doc = the_docs[i];
    bib_id = $( "form", the_doc ).attr( "data-doc-id" );
    getAvailabilityData( the_doc, bib_id );
  }
}

function getAvailabilityData( the_doc, bib_id ) {
  /* Grabs item's availability data and triggers div's html creation.
   * Called by grabItemDivs() */
  api_url = "http://library.brown.edu/services/availability/id/" + bib_id + "/?callback=?";
  $.getJSON(
    api_url,
    function( response_object, success_status, ajax_object ) {  // these 3 vars are auto-created by $.getJSON; we only care about the response_object...
      populateDiv( response_object, the_doc );  // ...and our `the_doc`, which requires the anonymous function syntax to pass it along
    }
  );
}

function populateDiv( response_object, the_doc) {
  /* Determines item's overall availability and updates html.
   * Called by getAvailabilityData() */
  var availability_status = "unknown";
  if (response_object['items'].length > 0 ) {
    availability_status = checkAvailability( response_object );
  }
  availability_html = buildAvailabilityHtml( availability_status );
  $( the_doc ).append( availability_html );
  // $( the_doc ).append( "<pre>" + JSON.stringify(response_object, undefined, 2) + "</pre>" );
}

function checkAvailability( response_object ) {
  /* Determines and returns item's summarized availability.
   * Called by populateDiv() */
  var return_status = "init";
  for ( var index_key in response_object["items"] ){
    item = response_object["items"][index_key]
    if ( item["is_available"] == true ) {
      return_status = "available";
      break;
    } else if ( item["is_available"] == false ) {
      return_status = "unavailable";
    }
  }
  return return_status;
}

function buildAvailabilityHtml( availability_status ) {
  /* Builds availability html. (TODO: replace color with css classes.)
   * Called by populateDiv() */
  var color_dict = { "available": "green", "unavailable": "red", "unknown": "purple" };
  availability_html = [
    '<dl class="document-metadata dl-horizontal dl-invert">',
      '<dt class="blacklight-summary_availability">Availability:</dt>',
      '<dd class="blacklight-summary_availability">',
        '<span class="summary_availability" style="color:' + color_dict[availability_status] + '">' +availability_status + '</span>',
      '</dd>',
    '</dl>'
  ].join('\n');
  return availability_html;
}

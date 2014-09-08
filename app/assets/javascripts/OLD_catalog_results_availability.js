/*
- Grabs item divs, and for each item...
  - Checks that availability info hasn't already been created (addressing a Safari event issue)
  - Gets bib_id
  - Hits availability api.
  - Determines summary availability.
  - Builds html & inserts it into dom.
- Loaded by `app/views/catalog/_search_results.html.erb`.
*/

$(document).on(  // $(document).ready... is problematic, see <http://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbolinks>
  "page:change",
  function() {
    grabItemDivs();
  }
);

function grabItemDivs() {
  /* Triggers ajax call for every item-div if necessary.
   * Called on doc.on() */
  the_docs = $( ".document" );
  for (var i = 0; i < the_docs.length; i++) {
    the_doc = the_docs[i];
    target_span = $( ".summary_availability", the_doc );  // check to see if the dom has already been updated (Safari event issue)
    if ( target_span.length == 0 ) {
      bib_id = $( "form", the_doc ).attr( "data-doc-id" );
      getAvailabilityData( the_doc, bib_id );
    }
  }
}

function getAvailabilityData( the_doc, bib_id ) {
  /* Grabs item's availability data and triggers div's html creation.
   * Called by grabItemDivs() */
  api_url = "http://library.brown.edu/services/availability/id/" + bib_id + "/?callback=?";
  $.getJSON(
    api_url,
    function( response_object, success_status, ajax_object ) {  // these 3 vars are auto-created by $.getJSON; we only care about the response_object...
      determineAvailability( response_object, the_doc );  // ...and our `the_doc`, which requires the anonymous function syntax to pass it along
    }
  );
}

function determineAvailability( response_object, the_doc ) {
  /* Determines item's summarized availability; triggers html creation.
   * Called by getAvailabilityData() */
  var availability_status = "unknown";
  for ( var index_key in response_object["items"] ){
    item = response_object["items"][index_key]
    if ( item["is_available"] == true ) {
      availability_status = "available";
      break;
    } else if ( item["is_available"] == false ) {
      availability_status = "unavailable";
    }
  }
  populateDiv( the_doc, availability_status );
}

function populateDiv( the_doc, availability_status ) {
  /* Builds and updates html.
   * Called by getAvailabilityData() */
  availability_html = buildAvailabilityHtml( availability_status );
  $( the_doc ).append( availability_html );
}

function buildAvailabilityHtml( availability_status ) {
  /* Builds availability html. (TODO: replace color with css classes.)
   * Called by populateDiv() */
  color_dict = { "available": "green", "unavailable": "red", "unknown": "purple" };
  context = {
      "availability_color": color_dict[availability_status],
      "availability_status": availability_status
  };
  availability_html = HandlebarsTemplates['catalog/ctlg_rslts_avlblty'](context);
  return availability_html;
}

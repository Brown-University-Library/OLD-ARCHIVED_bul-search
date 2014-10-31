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
  api_url = availabilityService + bib_id + "/?callback=?";
  $.getJSON(
    api_url,
    function( response_object, success_status, ajax_object ) {  // these 3 vars are auto-created by $.getJSON; we only care about the response_object...
      context = {};
      //determineAvailability( response_object, the_doc, bib_id );  // ...and our `the_doc`, which requires the anonymous function syntax to pass it along
      if (response_object['items'].length > 0) {
        context = response_object;
        context['show_ezb_button'] = false;
        context['openurl'] = null;
        context['class'] = 'results';
        context['results'] = true;
        $(the_doc).append( html );
      } else if (response_object['summary']) {
        context['results'] = true;
        context['summary'] = response_object['summary']
      };
      html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
    }
  );
}

function determineAvailability( response_object, the_doc, bib_id ) {
  /* Determines item's summarized availability, whether easyBorrow button should display, and triggers html creation.
   * Called by getAvailabilityData() */
  // console.log( 'determineAvailability() response_object, ' + JSON.stringify(response_object, undefined, 2) );
  var availability_status = "unknown"; var show_ezb_button = false; var openurl = null;
  if (response_object['items'].length > 0 ) {  //check for items before updating HTML.
    var available_item = _.find(  // _.find() stops processing on first find
      response_object['items'],
      function( item ) { if ( item['is_available'] == true ){ return item; } } );
    if ( ! available_item ) {
      availability_status = "unavailable"; show_ezb_button = true;
    } else {
      availability_status = "available"; show_ezb_button = false;
    }
    populateDiv( the_doc, availability_status, show_ezb_button, bib_id );
  }
}

function populateDiv( the_doc, availability_status, show_ezb_button, bib_id ) {
  /* Builds and updates html.
   * Called by determineAvailability() */
  class_status = 'status_' + availability_status
  availability_html = buildAvailabilityHtml( availability_status, class_status, show_ezb_button, bib_id );
  $( the_doc ).append( availability_html );
}

function buildAvailabilityHtml( availability_status, class_status, show_ezb_button, bib_id ) {
  /* Builds availability html.
   * Called by populateDiv() */
  context = {
      'class_status': class_status,
      'availability_status': availability_status,
      'show_ezb_button': show_ezb_button,
      'bib_id': bib_id
  };
  availability_html = HandlebarsTemplates['catalog/catalog_results_availability_display'](context);
  return availability_html;
}


/*
 * On 'Request' button click...
 */

function redirect_ezaccess( bib_id ) {
  /* Gets openurl and redirects to easyAccess landing page.
   * Called on button click. */
  var record_path = $('#record-path').text();
  $.get( record_path + bib_id + "/ourl", function( data ) {
    openurl = 'https://library.brown.edu/easyarticle/borrow/?' + data['ourl'];
    location.href = openurl;
    }
  );
}

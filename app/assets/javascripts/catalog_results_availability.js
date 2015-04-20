/*
- Grabs item divs, and for each item...
  - Checks that availability info hasn't already been created (addressing a Safari event issue)
  - Gets bib_id
  - Hits availability api.
  - Displays holdings table.
- Loaded by `app/views/catalog/_search_results.html.erb`.
*/

var locateLocations = [
  'rock'
]
var locatorViewURL = 'http://localhost:5000/'
var locatorDataURL = 'http://localhost:5000/data/'

$(document).on(  // $(document).ready... is problematic, see <http://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbolinks>
  "page:change",
  function() {
    grabItemDivs();
    console.debug(locatorDataURL);
  }
);

function grabItemDivs() {
  /* Triggers ajax call for every item-div if necessary.
   * Called on doc.on() */
  the_docs = $( ".document" );
  for (var i = 0; i < the_docs.length; i++) {
    the_doc = the_docs[i];
    target_span = $( ".summary-availability", the_doc );  // check to see if the dom has already been updated (Safari event issue)
    if ( target_span.length == 1 ) {
      bib_id = $( target_span ).attr( "data-id" );
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
      } else if ($.isEmptyObject(response_object['summary']) != true) {
        context['summary'] = response_object['summary']
      };
      //Make sure we have something to show.
      if ($.isEmptyObject(context) != true) {
        context['results'] = true;

        if ((context['items'] !== undefined) && (context['items'].length > 2)) {
          context['items'] = context['items'].slice(0, 2);
          context['more'] = true;
          context['more_link'] = './catalog/' + bib_id;
        }
        html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
        $(the_doc).append( html );
      }
    }
  );
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

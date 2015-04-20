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
    //grabItemDivs();
    collectBibs();
  }
);

function collectBibs() {
  var bibs = [];
  $.each($('.summary-availability'), function(i, bib) {
      bibs.push($(bib).data('id'));
  });
  getAvailability(bibs);
}


function getAvailability(bibs) {
    console.log(bibs);
    //postLocator(items);
    $.ajax({
        type: "POST",
        url: 'http://localhost:5000/bib/',
        //dataType: 'json',
        //contentType: "application/json",
        data: JSON.stringify(bibs),
        success: function (data) {
            $.each(data, function(bib, context){
              context['results'] = true;
              context['items'] = _.filter(context['items'], function(item){ return item['location'] != 'ONLINE BOOK'})
              console.debug(bib);
              console.debug(context);
              var elem = $('[data-id="' + bib + '"]');
              html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
              $(elem).append(html);
              $(elem).removeClass('hidden');
            });
        }
    })
}

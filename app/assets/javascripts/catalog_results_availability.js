/*
- Grabs item divs, and for each item...
  - Checks that availability info hasn't already been created (addressing a Safari event issue)
  - Gets bib_id
  - Hits availability api.
  - Displays holdings table.
- Loaded by `app/views/catalog/_search_results.html.erb`.
*/

$(document).on(  // $(document).ready... is problematic, see <http://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbolinks>
  "page:change",
  function() {
    collectBibs();
  }
);

function collectBibs() {
  var bibs = [];
  $.each($('.index_title'), function(i, bib) {
      bibs.push($(bib).data('id'));
  });
  getAvailability(bibs);
}

function getTitle(bib) {
  return $('[data-id="' + bib + '"] a').text();
}

//POST the list of bis to the service.
function getAvailability(bibs) {
    $.ajax({
        type: "POST",
        //url: 'https://apps.library.brown.edu/bibutils/bib/',
        url: availabilityService,
        //dataType: 'json',
        //contentType: "application/json",
        data: JSON.stringify(bibs),
        success: function (data) {
            $.each(data, function(bib, context){
              if (context) {
                context['results'] = true;
                //context.items = _.filter(context['items'], function(item){ return (item['location'] != 'ONLINE BOOK') && (item['location'] != 'ONLINE SERIAL')})
                context['items'] = _.each(context['items'], function(item) {item['map'] = item['map'] + '&title=' + getTitle(bib)});
                if (context['has_more'] == true) {
                  context['more_link'] = window.location.pathname + '/' + bib + '?limit=false';
                };
                var elem = $('[data-availability="' + bib + '"]');
                html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
                $(elem).append(html);
                $(elem).removeClass('hidden');
              };
            });
        }
    })
}
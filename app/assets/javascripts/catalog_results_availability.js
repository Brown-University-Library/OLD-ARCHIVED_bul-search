//
// - Grabs item divs, and for each item...
//   - Checks that availability info hasn't already been created (addressing a Safari event issue)
//   - Gets bib_id
//   - Hits availability api.
//   - Displays holdings table.
// - Loaded by `app/views/catalog/_search_results.html.erb`.
//
// Global variables:
//      availabilityService
//

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


function getItemData(bib) {
  var i;
  for(i = 0; i < bibsData.length; i++) {
    if (bibsData[i].id == bib) {
      // TODO:
      // Currently the author is always empty because we don't load the MARC
      // data for search results which is where the author is buried under the
      // statement_of_responsibility field. We should change this.
      return {title: bibsData[i].title, found_author: bibsData[i].author, format: bibsData[i].format};
    }
  }
  return {title: "", found_author: "", format: ""};
}

//POST the list of bis to the service.
function getAvailability(bibs) {
  if (!availabilityService) {
    return;
  }

    $.ajax({
        type: "POST",
        url: availabilityService,
        data: JSON.stringify(bibs),
        success: function (data) {
            $.each(data, function(bib, context){
              if (context) {
                context['results'] = true;

                if (context['has_more'] == true) {
                  context['more_link'] = window.location.pathname + '/' + bib + '?limit=false';
                };

                _.each(context['items'], function(item) {
                  // console.log( "item..." );
                  // console.log( item );
                  var itemData = getItemData(bib);
                  // console.log( "itemData..." );
                  // console.log( itemData );
                  item['map'] = item['map'] + '&title=' + itemData.title;
                  if (canScanItem(item['location'], itemData.format)) {
                    item['scan'] = easyScanFullLink(item['scan'], bib, itemData.title);
                    item['item_request_url'] = itemRequestFullLink(item['barcode'], bib);
                  } else {
                    item['scan'] = null;
                    item['item_request_url'] = null;
                  }

                  // add jcb link if necessary
                  if ( item['location'].slice(0, 3) == "JCB" ) {
                    item['jcb_url'] = jcbRequestFullLink( bib, itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber'] );
                  }

                  // add hay aeon link if necessary
                  if ( item['location'].slice(0, 3) == "HAY" ) {
                    if ( isValidHayAeonLocation(item['location']) == true ) {
                      item['hay_aeon_url'] = hayAeonFullLink( bib, itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber'], item['location'] );
                    }
                  }

                });

                var elem = $('[data-availability="' + bib + '"]');
                html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
                $(elem).append(html);
                $(elem).removeClass('hidden');
              };
            });
        }
    })
}

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

function getItemData(bib) {
    var element = $('[data-id="' + bib + '"]');
    var title = element.find('a').text();
    return {title: title, format: element.data('format')};
}

//POST the list of bis to the service.
function getAvailability(bibs) {
    $.ajax({
        type: "POST",
        //url: 'https://apps.library.brown.edu/bibutils/bib/',
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
                  console.log( "item..." );
                  console.log( item );
                  var itemData = getItemData(bib);
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
                    item['jcb_url'] = jcbRequestFullLink( bib, itemData.title, getAuthor(), getPublisher(), item['callnumber'] );
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


function getAuthor() {
  // for jcb link //
  var author = $('div[class="title-subheading"]')[0].textContent.slice( 0, 100 );
  return author;
}


function getPublisher() {
  // for jcb link //
  var publisher = "unavailable in result-list";
  return publisher;
}

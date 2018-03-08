// JavaScript functions for search results.
// Loaded by `app/views/catalog/_search_results.html.erb`.
$(document).ready(function() {
  var scope = {};

  // Get the data from the global variables into local variables.
  // Ideally these should be scope.x but for convenience they are just x.
  var bibsData = window.bibsData;                       // defined in _search_results.html.erb
  var availabilityService = window.availabilityService; // defined in app/views/catalog/index.html.erb

  scope.Init = function() {
    var bibs = [];
    var i;
    for(i = 0; i < bibsData.length; i++) {
      bibs.push(bibsData[i].id);
    }
    scope.getAvailability(bibs);
  };


  scope.getItemData = function(bib) {
    var i;
    for(i = 0; i < bibsData.length; i++) {
      if (bibsData[i].id == bib) {
        return {title: bibsData[i].title, found_author: bibsData[i].author, format: bibsData[i].format};
      }
    }
    return {title: "", found_author: "", format: ""};
  };


  scope.getAvailability = function(bibs) {
    if (!availabilityService) {
      return;
    }

    $.ajax({
      type: "POST",
      url: availabilityService,
      data: JSON.stringify(bibs),
      success: scope.showAvailability
    });
  };


  scope.showAvailability = function(data) {
    $.each(data, function(bib, context){
      if (context) {
        context['results'] = true;

        if (context['has_more'] == true) {
          context['more_link'] = window.location.pathname + '/' + bib + '?limit=false';
        };

        _.each(context['items'], function(item) {
          var itemData = scope.getItemData(bib);
          item['map'] = item['map'] + '&title=' + itemData.title;

          // add scan|item links
          if (canScanItem(item['location'], itemData.format, item['status'])) {
            item['scan'] = easyScanFullLink(item['scan'], bib, itemData.title);
            item['item_request_url'] = itemRequestFullLink(item['barcode'], bib);
          } else {
            item['scan'] = null;
            item['item_request_url'] = null;
          }

          // add jcb link if necessary
          if (item['location'].slice(0, 3) == "JCB") {
            item['jcb_url'] = jcbRequestFullLink(bib, itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber']);
          }

          // add hay aeon link if necessary
          if (item['location'].slice(0, 3) == "HAY") {
            if (isValidHayAeonLocation(item['location']) == true) {
              item['hay_aeon_url'] = hayAeonFullLink(bib, itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber'], item['location']);
            }
          }
        });

        var elem = $('[data-availability="' + bib + '"]');
        var html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
        $(elem).append(html);
        $(elem).removeClass('hidden');
      };
    });
  };

  scope.Init();
}); // $(document).ready(function() {

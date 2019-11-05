// JavaScript functions for search results.
// Loaded by `app/views/catalog/_search_results.html.erb`.
$(document).ready(function() {
  var scope = {};

  // Get the data from the global variables into local variables.
  // Ideally these should be scope.x but for convenience they are just x.
  var bibsData = window.bibsData;                       // defined in _search_results.html.erb
  var availabilityService = window.availabilityService; // defined in app/views/catalog/index.html.erb
  var availabilityEZB = window.availabilityEZB;
  var isSolr7 = window.isSolr7;                         // defined in _search_results.html.erb

  scope.Init = function() {
    var bibs = [];
    var i, links, newUrl;
    for(i = 0; i < bibsData.length; i++) {
      bibs.push(bibsData[i].id);
    }
    scope.getAvailability(bibs);

    // == SOLR-7-MIGRATION
    if (isSolr7) {
      links = $("h5>a");
      for(i = 0; i < links.length; i++) {
        if (links[i].hasAttribute("data-context-href")) {
          // It's a show page link.
          // Make it a normal link (i.e. override the Blacklight POST mechanism)
          // and append the "s7" parameter;
          links[i].removeAttribute("data-context-href");
          newUrl = links[i].getAttribute("href") + "?s7"
          links[i].setAttribute("href", newUrl)
        }
      }

      links = $(".facet-label>a");
      for(i = 0; i < links.length; i++) {
        url = links[i].getAttribute("href");
        if (url.indexOf("/catalog?") > -1) {
          // It's a search URL.
          // Append the "s7" parameter
          newUrl = links[i].getAttribute("href") + "&s7"
          links[i].setAttribute("href", newUrl)
        }
      }

      links = $("a.remove");
      for(i = 0; i < links.length; i++) {
        url = links[i].getAttribute("href");
        if (url.indexOf("/catalog?") > -1) {
          // It's a search URL.
          // Append the "s7" parameter
          newUrl = links[i].getAttribute("href") + "&s7"
          links[i].setAttribute("href", newUrl)
        }
      }
    }
  };


  scope.getItemData = function(bib) {
    var i;
    for(i = 0; i < bibsData.length; i++) {
      if (bibsData[i].id == bib) {
        return {
          id: bib,
          title: bibsData[i].title,
          found_author: bibsData[i].author,
          format: bibsData[i].format
        };
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


  scope.showAvailability = function(data) { // could this interfere with `catalog_record_availability.js` -> `scope.showAvailability = function(all) {}`?
    $.each(data, function(bib, context){
      if (context) {
        context['results'] = true;

        if (context['has_more'] == true) {
          context['more_link'] = window.location.pathname + '/' + bib + '?limit=false';
        };

        // Used for showing "available via easyBorrow"
        var bibData = scope.getItemData(bib);
        var avItems = context['items'];
        context['bibURL'] = window.location.pathname + '/' + bib;
        context['ezbBIB'] = false; // See comment on scope.isEasyBorrowBib(bibData, avItems);

        _.each(context['items'], function(item) {
          var itemData = scope.getItemData(bib);
          item['map'] = item['map'] + '&title=' + itemData.title;

          // add scan|item links
          if (canScanItem(item['location'], itemData.format, item['status'])) {
            // Birkin: you can use bibData.format here
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
            // console.log( 'location-slice, `' + item['location'].slice(0, 3) + '`' );
            // console.log( 'isValidHayAeonLocation, `' + isValidHayAeonLocation(item['location']) + '`' );
            if (isValidHayAeonLocation(item['location']) == true) {
              // console.log( 'item->hay_aeon_url initially, `' + item['hay_aeon_url'] + '`' );
              item['hay_aeon_url'] = hayAeonFullLink(bib, itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber'], item['location']);
              // console.log( 'item->hay_aeon_url NOW, `' + item['hay_aeon_url'] + '`' );
            }
          }

          // add Annex-Hay `easyrequest_hay` link if necessary
          if ( (item['location'] == "ANNEX HAY") && (item['status'] == "AVAILABLE") && (item['callnumber'].toUpperCase().includes("RESTRICTED") == false) ) {
            console.log( 'itemData.format, `' + itemData.format + '`' );
            /* 2019-July: restrictions on "Archives/Manuscripts" items eased */
            // if ( itemData.format != "Archives/Manuscripts" ) {
            //   item['annexhay_easyrequest_url'] = easyrequestHayFullLink(bib, item['barcode'], itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber'], item['location']);
            // }
            item['annexhay_easyrequest_url'] = easyrequestHayFullLink(bib, item['barcode'], itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber'], item['location']);
          }

        });

        var elem = $('[data-availability="' + bib + '"]');
        var html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
        $(elem).append(html);
        $(elem).removeClass('hidden');
      };
    });
  };

  // TODO: Once we get this working, see if we can move it to application.js
  scope.isEasyBorrowBib = function(bibData, avItems) {
    var i
    var hasAvailableItems = false;
    var hasEasyBorrowItems = false;

    // Currently I cannot get this to work because we don't have the itemsMultiType
    // value calculated here (like we do for individual catalog records).
    //
    // The information that the availability API returns for the items does not
    // let me determine whether this record is multi-copy or single. I'll need to
    // fetch the MARC data form Solr on the search and calculate the value via
    // the SolrDocument code already in place for individual records.
    //
    // var allowEasyBorrow = (bibData.itemsMultiType == "copy" || bibData.itemsMultiType == "single");
    var allowEasyBorrow = (avItems.length == 1); // same as "single"

    if (!availabilityEZB) {
      console.log("ezb bib: disabled");
      return false;
    } else if (!allowEasyBorrow) {
      console.log("ezb bib: not applicable for " + bibData.id);
      return false;
    }

    for (i = 0; i < avItems.length; i++) {
      if (isAvailableStatus(avItems[i]["status"])) {
        hasAvailableItems = true;
      } else if (isTakeHomeLocation(avItems[i]["location"])) {
        hasEasyBorrowItems = true;
      }
    }

    if (!hasAvailableItems && hasEasyBorrowItems) {
      console.log("ezb bib " + bibData.id + ": yes");
      return true;
    }

    console.log("ezb bib " + bibData.id + ": no (av:" + hasAvailableItems + ", ezb:" + hasEasyBorrowItems + ")");
    return false;
  };


  scope.Init();
}); // $(document).ready(function() {

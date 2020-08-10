// JavaScript functions for search results.
// Loaded by `app/views/catalog/_search_results.html.erb`.
$(document).ready(function() {
  var scope = {};

  // Get the data from the global variables into local variables.
  // Ideally these should be scope.x but for convenience they are just x.
  var bibsData = window.bibsData;                       // defined in _search_results.html.erb
  var availabilityService = window.availabilityService; // defined in app/views/catalog/index.html.erb
  var itemService = window.itemService;                 // defined in app/views/catalog/index.html.erb
  var availabilityEZB = window.availabilityEZB;

  // Locations from where we allow requesting during the re-opening phase.
  // (defined via ENV variable)
  var reopeningLocations = (window.reopeningLocations || []);

  // Controls whether we show the new "Request Item" link instead of the "Request This (bib)" link.
  var isRequestItemLink = (window.isRequestItemLink === true) || (josiahObject.getUrlParameter("req") == "item");

  scope.Init = function() {
    var bibs = [];
    for(i = 0; i < bibsData.length; i++) {
      bibs.push(bibsData[i].id);
    }
    scope.getAvailability(bibs);
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
    // Array of links of bibs without a barcode that we need to patch
    // (see patchRequestItemLinks() below)
    var bibsToPatch = [];

    $.each(data, function(bib, context){
      var requestableBib;
      if (context) {
        context['results'] = true;

        if (context['has_more'] == true) {
          context['more_link'] = window.location.pathname + '/' + bib + '?limit=false';
        };

        requestableBib = (context['requestable'] === true);

        // Used for showing "available via easyBorrow"
        context['bibURL'] = window.location.pathname + '/' + bib;
        context['ezbBIB'] = false; // See comment on scope.isEasyBorrowBib(bibData, avItems);

        _.each(context['items'], function(item) {
          var itemData = scope.getItemData(bib);
          var itemRequestData = {
            requestableBib: requestableBib,
            reopeningLocations: reopeningLocations,
            location: item['location'],
            status: item['status'],
          }
          var showRequestItemLink = isRequestItemLink && canRequestItem(itemRequestData);

          item['map'] = item['map'] + '&title=' + itemData.title;

          // add scan|item links
          if (canScanItem(item['location'], itemData.format, item['status'])) {
            item['scan'] = easyScanFullLink(item['scan'], bib, itemData.title);
            item['item_request_url'] = itemRequestFullLink(item['barcode'], bib, '');
            showRequestItemLink = false;
            if (item['barcode'] == null || item['barcode'] == "") {
              bibsToPatch.push(bib);
            }
          } else {
            // Must null these values to prevent the "scan|(gray)item" scenario when rendering.
            item['scan'] = null;
            item['item_request_url'] = null;
          }

          // add jcb link if necessary
          if (item['location'].slice(0, 3) == "JCB") {
            item['jcb_url'] = jcbRequestFullLink(bib, itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber']);
            showRequestItemLink = false;
          }

          // add hay aeon link if necessary
          if (item['location'].slice(0, 3) == "HAY") {
            if (isValidHayAeonLocation(item['location']) == true) {
              item['hay_aeon_url'] = hayAeonFullLink(bib, itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber'], item['location']);
              showRequestItemLink = false;
            }
          }

          // add Annex-Hay `easyrequest_hay` link if necessary
          if ( (item['location'] == "ANNEX HAY") && (item['status'] == "AVAILABLE") && (item['callnumber'].toUpperCase().includes("RESTRICTED") == false) ) {
            item['annexhay_easyrequest_url'] = easyrequestHayFullLink(bib, item['barcode'], itemData.title, itemData.found_author, "publisher-unavailable", item['callnumber'], item['location']);
            showRequestItemLink = false;
          }

          if (showRequestItemLink) {
            item['request_item'] = itemRequestFullLink(item['barcode'], bib, '');
            if (item['barcode'] == null || item['barcode'] == "") {
              bibsToPatch.push(bib);
            }
          }
        });

        var elem = $('[data-availability="' + bib + '"]');
        var html = HandlebarsTemplates['catalog/catalog_record_availability_display'](context);
        $(elem).append(html);
        $(elem).removeClass('hidden');
      };
    });

    if (bibsToPatch.length > 0) {
      console.log("Attempting patch for " + bibsToPatch.toString() + " bibs");
      scope.patchRequestItemLinks(bibsToPatch);
    } else {
      console.log("No patching needed");
    }
  };

  // Find all the "request" links that don't have an item number
  // in the URL and see if we can get one from the backend and
  // patch the URLs.
  scope.patchRequestItemLinks = function(bibs) {
    $.ajax({
      type: "GET",
      url: itemService + "?bibs=" + bibs.join(),
      success: function(itemInfo) {
        // Loop through all the links...
        $(".scan").each(function() {
          var i, newUrl;
          var url = $(this).attr("href");
          var bib = scope.urlNeedItemNumPatch(url);
          if (bib != null) {
            // ...patch it with the info that we got in the AJAX call
            for(i = 0; i < itemInfo.length; i++) {
              if (itemInfo[i].bib == bib) {
                if (itemInfo[i].items.length == 1) {
                  newUrl = url.replace("&itemnum=", "&itemnum=" + itemInfo[i].items[0]);
                  $(this).attr("href", newUrl);
                  console.log("PATCHED " + newUrl);
                } else if (itemInfo[i].items.length > 1) {
                  console.log("CANNOT PATCH (>1) " + newUrl);
                }
                break;
              }
            }
          }
        }); // .each
      }
    }); // .ajax
  }

  // Returns the bib number in the URL if the URL needs to have its itemnum
  // patched, otherwise it returns null.
  scope.urlNeedItemNumPatch = function(url) {
    var itemId, needPatch;
    var urlTokens = url.split("?");
    var bib = null;
    if (urlTokens.length > 1) {
      bib = getUrlParameterFromString(urlTokens[1], "bibnum");
      itemId = getUrlParameterFromString(urlTokens[1], "itemnum");
      needPatch = (bib != null) && (itemId == "");
      if (needPatch) {
        return bib;
      }
    }
    return null;
  }

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

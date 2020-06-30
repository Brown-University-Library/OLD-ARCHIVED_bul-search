// JavaScript functions for individual catalog records.
// Loaded by `app/views/catalog/show.html.erb`.
$(document).ready(function() {
  var scope = {};

  // Get the data from the global variables into local variables.
  // Ideally these should be scope.x but for convenience they are just x.
  var bibData = window.bibData;                         // defined in _show_default.html.erb
  var itemsData = window.itemsData;                     // defined in _show_default.html.erb
  var availabilityService = window.availabilityService; // defined in _show_default.html.erb
  var availabilityEZB = window.availabilityEZB;         // defined in _show_default.html.erb
  var josiahRootUrl = window.josiahRootUrl;             // defined in app/views/shared/_header_navbar.html.erb
  var josiahObject = window.josiahObject;               // defined in app/assets/javascripts/application.js

  // Controls the "The library is currently closed..." banner at the top of the page.
  var isCovid = (window.isCovid === true);

  // Locations from where we allow requesting during the re-opening phase.
  // (defined via ENV variable)
  var reopeningLocations = (window.reopeningLocations || []);

  // Controls whether we show request options for certain locations.
  var isReopening = (window.isReopening === true) || (josiahObject.getUrlParameter("reopening") == "true");

  // Don't show the Hathi Emergency Temporary Access once we start the reopening phase.
  var isHathiETA = !isReopening;

  scope.Init = function() {
    var req, apiUrl, limit;

    scope.addOcraLink(bibData.id);
    scope.addBookServicesLink();
    scope.addVirtualShelfLinks(bibData.id);

    if (availabilityService) {
      apiUrl = availabilityService + bibData.id + "/?callback=?";
      limit = josiahObject.getUrlParameter("limit");
      if (limit == "false") {
        apiUrl += "&limit=false";
      }
    }

    if (apiUrl && bibData.showAvailability) {
      // We are using .ajax() rather than .getJSON() here to be able
      // to handle errors (https://stackoverflow.com/a/5121811/446681)
      // The timeout value is required for the error() function to be called!
      console.log( 'apiUrl, ```' + apiUrl + '```' )
      req = $.ajax({url: apiUrl, dataType: "jsonp", timeout: 5000});
      req.success(scope.addAvailability);
      req.error(scope.errAvailability);
    } else {
      scope.showAvailability(true);
      scope.showAeon();
      scope.debugMessage("Skipped call to Availability API");
    }

    if (location.search.indexOf("nearby") > -1) {
      scope.loadNearbyItems(false);
    }

    if (isHathiETA) {
      scope.showHathiEmergencyLinks(bibData.oclcNums);
    } else {
      scope.showHathiLink(bibData.oclcNum);
    }
    scope.debugMessage("BIB record multi: " + bibData.itemsMultiType)
  };


  scope.getItemByBarcode = function(barcode) {
    var i;
    if (barcode == null || barcode == "") {
      return null;
    }
    for(i = 0; i < itemsData.length; i++) {
      if (itemsData[i].barcode == barcode) {
        return itemsData[i];
      }
    }
    return null;
  };


  scope.getItemByCallnumber = function(avCallnumber) {
    var i, candidates, marcCallnumber;
    if (avCallnumber == null || avCallnumber == "") {
      return null;
    }

    for(i = 0; i < itemsData.length; i++) {
      marcCallnumber = itemsData[i].call_number;
      if (marcCallnumber != null && marcCallnumber == avCallnumber) {
        // we found an exact match.
        return itemsData[i];
      }
    }

    // The call number that we have in the MARC record is partial
    // because we don't get all the item data. For example the "1-SIZE"
    // sometimes is in the 091f (https://search.library.brown.edu/catalog/b6615023
    // or the edition information is in an item field that is not included
    // in our MARC files (e.g. "94th ed" in https://search.library.brown.edu/catalog/b6615023)
    //
    // Hence, we do partial match (indexOf) here to try to match the
    // MARC call numbers with the ones returned by the Availability API.
    candidates = [];
    for(i = 0; i < itemsData.length; i++) {
      marcCallnumber = itemsData[i].call_number;
      if (marcCallnumber != null && avCallnumber.indexOf(marcCallnumber) != -1) {
       candidates.push(itemsData[i]);
      }
    }
    if (candidates.length == 1) {
      // yay! we got a single match.
      return candidates[0];
    }
    return null;
  };


  scope.getBibId = function() { return bibData.id; };
  scope.getTitle = function() { return bibData.title; };
  scope.getFormat = function() { return bibData.format; };
  scope.getAuthor = function() { return bibData.author; };
  scope.getPublisher = function() { bibData.publisher; };


  scope.getItemById = function(id) {
    var i;
    if (id == null || id == "") {
      return null;
    }
    for(i = 0; i < itemsData.length; i++) {
      if (itemsData[i].id == id) {
        return itemsData[i];
      }
    }
    return null;
  };


  scope.addOcraLink = function(bib_id) {
    var ocraUrl = "https://library.brown.edu/reserves/cr/ocrify/?bibnum=" + bib_id;
    var helpInfo = "Staff and Teaching Assistants can reserve this item in OCRA for courses they teach.";
    var link = '<li><a href="' + ocraUrl + '" title="' + helpInfo + '" target="_blank">Add to OCRA</a>';
    $("div.panel-body>ul.nav").append(link);
  };


  scope.addBookServicesLink = function() {
    // hidden by default
    var li = '<li id="book_services_link" class="hidden">';
    var helpInfo = "Request this item to be paged (Faculty and Grad/Med students only)";
    var a = '<a href="' + bibData.bookServicesUrl + '" title="' + helpInfo + '" target="_blank">Request This</a>';
    var html = li + a;
    $("div.panel-body>ul.nav").append(html);
  };


  scope.addAvailability = function(availabilityResponse) {
    // Realtime status of items (and other item specific information)
    console.log( 'starting addAvailability()' )
    _.each(availabilityResponse.items, function(avItem) {
      scope.updateItemInfo(avItem);
    });

    if (availabilityResponse.has_more == true) {
      $("#show_more_items").removeClass("hidden");
      scope.showAvailability(false);
    } else {
      scope.showAvailability(true);
    }

    if (availabilityResponse.requestable) {
      if (isReopening) {
        var i, status;
        var location = "N/A";
        var requestOK = false;
        for(i = 0; i < availabilityResponse.items.length; i++) {
          location = (availabilityResponse.items[i].location || "").toUpperCase();
          status = (availabilityResponse.items[i].status || "");
          if (reopeningLocations.includes(location)) {
            if (status.includes("HOLD")) {
              // skip it
            } else {
              requestOK = true;
              break;
            }
          }
        }
        if (requestOK) {
          $("#book_services_link").removeClass("hidden");
          scope.debugMessage("Requestable, location: " + location);
        } else {
          scope.debugMessage("Not requestable, location: " + location);
        }
      } // reopening
    } // requestable

    scope.showEasyBorrowBib(availabilityResponse.items);
    scope.showHoldingsSummary(availabilityResponse.summary);
  };


  scope.errAvailability = function() {
    // show whatever we have from the MARC data already on the HTML
    scope.debugMessage("Availability API error, using MARC data instead");
    scope.showAvailability(true);
    scope.showAeon();
  };


  scope.showHathiLink = function(oclcNum) {
    if (oclcNum == "") {
      scope.debugMessage("Skipped call to Hathi");
      return;
    }
    // Source: http://josiah.brown.edu/screens/josiah_helpers.js
    var url = "https://catalog.hathitrust.org/api/volumes/brief/oclc/" + oclcNum + ".json";
    var i, item, html;
    $.getJSON(url, function (ht) {
      if (ht.items.length == 0) {
        scope.debugMessage("No Hathi items found for " + oclcNum);
      } else {
        for(i = 0; i < ht.items.length; i++) {
          item = ht.items[i];
          if (item.rightsCode == 'pd') {
            var html = "<li><a id=\"hathi\" href=\"" + item.itemURL + "\" target=\"_blank;\">Full text from Hathi Trust</a>"
            $('#online_resources').removeClass("hidden");
            $("#online_resources_links").append(html);
            //break after first public domain full text link
            scope.debugMessage("Found public domain Hathi link for " + oclcNum);
            return;
          }
        }
        scope.debugMessage("No public domain Hathi link found for " + oclcNum);
      }
    });
  };

  // Hathi documentation:
  //     https://www.hathitrust.org/hathifiles
  //     https://www.hathitrust.org/bib_api
  //
  // Examples:
  //     https://catalog.hathitrust.org/api/volumes/brief/oclc/ocm40783780.json
  //     https://catalog.hathitrust.org/api/volumes/brief/json/oclc:ocm40783780;oclc:40783780;
  //
  // Hathi typical links:
  //     Normal case             https://search.library.brown.edu/catalog/b4041408
  //
  // Hathi emergency links:
  //     Single link             https://search.library.brown.edu/catalog/b3019671
  //     Multiple OCLC numbers   https://search.library.brown.edu/catalog/b2301113
  //     Multiple volumes        https://search.library.brown.edu/catalog/b1841334
  scope.showHathiEmergencyLinks = function(oclcNums) {
    var i, oclcNumString, url;

    oclcNumString = "";
    for(i = 0; i < oclcNums.length; i++) {
      if (bibData.id == "b6496967") {
        if ((oclcNums[i] == "ocm00000004") || (oclcNums[i] == "00000004")) {
          scope.debugMessage("Ignore known OCLC mismatch");
          continue;
        }
      }
      if (bibData.id == "b1710098") {
        if ((oclcNums[i] == "ocm00000660") || (oclcNums[i] == "00000660")) {
          scope.debugMessage("Ignore known OCLC mismatch");
          continue;
        }
      }
      oclcNumString += "oclc:" + oclcNums[i] + ";"
    }

    if (oclcNumString == "") {
      scope.debugMessage("Skipped call to Hathi (no OCLC numbers available)");
      return;
    }

    // Call the Hathi API with one or many OCLC numbers
    // https://www.hathitrust.org/bib_api
    //
    url = "https://catalog.hathitrust.org/api/volumes/brief/json/" + oclcNumString;
    $.getJSON(url, function (ht) {
      var items, i, item, itemFound, html;
      if (!ht.hasOwnProperty(oclcNumString) || (ht[oclcNumString].items.length == 0)) {
        scope.debugMessage("No Hathi items found for " + oclcNumString);
        return;
      }

      html = "";
      itemFound = false;
      items = ht[oclcNumString].items;

      // See if we got a public domain link from Hathi
      for(i = 0; i < items.length; i++) {
        item = items[i];
        if (item.rightsCode == 'pd') {
          itemFound = true;
          if (item.enumcron == false) {
            // If this is not a chronology bail out as soon as we find one link
            html = "<li><a id=\"hathi\" href=\"" + item.itemURL + "\" target=\"_blank;\">Full text from Hathi Trust</a>";
            break;
          } else {
            // Append this chronology to the list
            html += "<li><a id=\"hathi\" href=\"" + item.itemURL + "\" target=\"_blank;\">Full text from Hathi Trust - " + item.enumcron + "</a>";
          }
        }
      }

      if (itemFound) {
        $('#online_resources').removeClass("hidden");
        $("#online_resources_links").append(html);
        scope.debugMessage("Found public domain Hathi link for " + oclcNumString);
        return;
      }

      // See if we can find out a temporary link for the Hathi version
      for(i = 0; i < items.length; i++) {
        item = items[i];
        if (item.rightsCode == 'ic') {
          itemFound = true;
          if (item.enumcron == false) {
            // If this is not a chronology bail out as soon as we find one link
            html = "<li><a id=\"hathi\" href=\"" + item.itemURL + "\" target=\"_blank;\">Temporary Digital Access from Hathi Trust</a>";
            break;
          } else {
            // Append this chronology to the list
            html += "<li><a id=\"hathi\" href=\"" + item.itemURL + "\" target=\"_blank;\">Temporary Digital Access from Hathi Trust - " + item.enumcron + "</a>";
          }
        }
      }

      if (itemFound) {
        $('#online_resources').removeClass("hidden");
        $("#online_resources_links").append(html);
        scope.debugMessage("Temporary Hathi link for " + oclcNumString);
        return;
      }

      scope.debugMessage("No Hathi link found for " + oclcNumString);
    }); // $.getJSON
  }; // scope.showHathiEmergencyLinks

  scope.showAvailability = function(all) {
    var i;
    var limit = josiahObject.getUrlParameter("limit");
    var items = $(".bib_item");
    for (i = 0; i < items.length; i++) {
      if (all || i < 10) {
        $(items[i]).removeClass("hidden");
      }
    }
  };


  scope.showAeon = function() {
    console.log( 'starting showAeon()' );
    var i, item, row, barcode, status;
    for(i = 0; i < itemsData.length; i++) {
      item = itemsData[i];
      row = scope.rowForItem(item);
      barcode = null;
      console.log( 'barcode, `' + barcode + '`' );
      status = null;
      scope.updateItemAeonLinks(row, item, barcode, status);
    }
  };


  scope.showEasyBorrowBib = function(avItems) {
    var i
    var hasAvailableItems = false;
    var hasEasyBorrowItems = false;
    var allowEasyBorrow = (bibData.itemsMultiType == "copy" || bibData.itemsMultiType == "single");

    // During COVID-19 we don't offer EasyBorrow.
    return;

    if (!availabilityEZB) {
      // console.log("ezb bib: disabled");
      return;
    } else if (!allowEasyBorrow) {
      // console.log("ezb bib: not applicable");
      return;
    }

    for (i = 0; i < avItems.length; i++) {
      if (scope.isAvailableStatus(avItems[i]["status"])) {
        hasAvailableItems = true;
      } else if (scope.isTakeHomeLocation(avItems[i]["location"])) {
        hasEasyBorrowItems = true;
      }
    }

    if (!hasAvailableItems && hasEasyBorrowItems) {
      // console.log("ezb bib: yes");
      $("#request-copy-ezb").removeClass("hidden");
    } else {
      // console.log("ezb bib: no (av:" + hasAvailableItems + ", ezb:" + hasEasyBorrowItems + ")");
    }
  };


  scope.showHoldingsSummary = function(holdings) {
    if (holdings.length == 0) {
      return;
    }
    var html, i, summary;
    html = "<h5><b>Holdings Summary</b></h5>";
    html += "<table style='font-size:90%;'>";
    for(i = 0; i < holdings.length; i++) {
      summary = holdings[i];
      for(j = 0; j < summary.length; j++) {
        html += "<tr>";
        html += '<td width="5%">&nbsp;</td>';
        html += '<td width="30%">' + summary[j].label + "</td>";
        html += "<td>" + summary[j].value + "</td>";
        html += "</tr>";
      }
      if (i < (holdings.length-1)) {
        html += "<tr><td>&nbsp;</td></tr>"; // separator
      }
    }
    html += "</table><br/>";
    $("#holdingsSummary").first().append(html);
  };


  scope.rowForItem = function(item) {
    return $("#item_" + item.id);
  };


  // Updates item information (already on the page) with the
  // extra information that we got from the Availability service.
  scope.updateItemInfo = function(avItem) {
    console.log( 'starting updateItemInfo()' )
    var item, barcode, callnumber, itemRow;

    barcode = avItem['barcode'] || "";
    callnumber = avItem['callnumber'] || "";

    if (barcode != "") {
      item = scope.getItemByBarcode(barcode);
      if (item == null) {
        scope.debugMessage("ERROR: barcode (" + barcode + ") not found in MARC item data");
        return;
      }
    } else {
      // For those items that do not a have barcode (e.g. HAY HARRIS items)
      // we try by callnumber, but this is not 100% accurate.
      item = scope.getItemByCallnumber(callnumber);
      if (item == null) {
        scope.debugMessage("ERROR: barcode (" + barcode + ") callnumber (" + callnumber + ") not found in MARC item data");
        return;
      }
    }

    itemRow = scope.rowForItem(item);

    if (item.call_number != callnumber) {
      // The call number in the MARC data is different from the one the
      // availability API returned. Prefer the one from the availability API.
      scope.debugMessage("WARN: call number mismatch for barcode " + barcode + ": <b>" + item.call_number  + "</b> vs <b>" + callnumber + "</b>");
      itemRow.find(".callnumber").html(callnumber);
      item.call_number = callnumber;
    }

    scope.updateItemLocation(itemRow, avItem);
    scope.updateItemStatus(itemRow, avItem, item.volume);
    scope.updateItemScanStatus(itemRow, avItem, barcode);
    scope.updateItemAeonLinks(itemRow, item, barcode, avItem.status);
  };


  scope.updateItemLocation = function(row, avItem) {
    var floor, aisle, mapText, mapUrl, html;

    if (avItem['location']) {
      row.find(".location").html(avItem['location']);
    }

    if (avItem['shelf'] && avItem['shelf']['floor'] && avItem['shelf']['aisle']) {
      floor = avItem['shelf']['floor'];
      aisle = avItem['shelf']['aisle'];
      mapText = "Level " + floor + ", Aisle " + aisle;
      if (avItem['map']) {
        mapUrl = avItem['map'] + '&title=' + scope.getTitle();
        html = "-- <a href=" + mapUrl + ">" + mapText + "</a>";
      } else {
        html = "-- " + mapText;
      }
      row.find(".location_map").html(html);
    }
  };


  scope.updateItemStatus = function(row, avItem, volume) {
    var status, location, offerEZB, url, text, tooltip, html;
    status = avItem["status"];
    if (status) {
      row.find(".status").html(status);
      location = avItem["location"];
      offerEZB = availabilityEZB && bibData.itemsMultiType == "volume" &&
        !scope.isAvailableStatus(status) && scope.isTakeHomeLocation(location);
      offerEZB = false; // TODO: enable once easyBorrow honors the volume parameter
      if (offerEZB) {
        // Allow the user to request this volume via easyBorrow.
        url = bibData.easyBorrowUrl;
        if (volume != "") {
            url += "&volume=" + volume;
        }
        text = "Request this volume via EasyBorrow";
        tooltip = "Our copy is not available at the moment, but we can try get it for you from other libraries";
        html = '<br/><a href="' + url + '" title="' + tooltip + '" target="_blank">' + text + '</a>';
        row.find(".ezb_volume_url").html(html);
      }
    }
  };


  scope.updateItemScanStatus = function(row, avItem, barcode) {
    var scanLink, itemLink, html;
    if (canScanItem(avItem['location'], bibData.format, avItem["status"])) {
      scanLink = '<a href="' + easyScanFullLink(avItem['scan'], bibData.id, bibData.title) + '" title="Request a scan of a section of this item.">scan</a>';
      itemLink = '<a href="' + itemRequestFullLink(barcode, bibData.id) + '" title="Request this item.">item</a>';
      // -- COVID still true, but item-requesting needs to be re-enabled
      // itemLink = '<span style="color:gray" title="Circulation of physical items is currently suspended. Please request a scan.">item</span>';
      // if (isCovid) {
      //   scanLink = '<span style="color:gray" title="Scanning of materials is currently suspended, contact us for other options.">scan</a>';
      //   itemLink = '<span style="color:gray" title="Circulation of physical items is currently suspended, contact us for other options.">item</span>';
      // }
      html = scanLink + " | " + itemLink;
      row.find(".scan").html(html);
    }
  };


  // scope.updateItemScanStatus = function(row, avItem, barcode) {
  //   var scanLink, itemLink, html;
  //   if (canScanItem(avItem['location'], bibData.format, avItem["status"])) {
  //     scanLink = '<a href="' + easyScanFullLink(avItem['scan'], bibData.id, bibData.title) + '" title="Request a scan of a section of this item.">scan</a>';
  //     itemLink = '<a href="' + itemRequestFullLink(barcode, bibData.id) + '" title="Request this item.">item</a>';
  //     // COVID
  //     itemLink = '<span style="color:gray" title="Circulation of physical items is currently suspended. Please request a scan.">item</span>';
  //     if (isCovid) {
  //       scanLink = '<span style="color:gray" title="Scanning of materials is currently suspended, contact us for other options.">scan</a>';
  //       itemLink = '<span style="color:gray" title="Circulation of physical items is currently suspended, contact us for other options.">item</span>';
  //     }
  //     html = scanLink + " | " + itemLink;
  //     row.find(".scan").html(html);
  //   }
  // };


  scope.updateItemAeonLinks = function(row, item, barcode, status) {
    console.log( 'starting updateItemAeonLinks()' );
    var url, html;
    var location = item.location_name;
    console.log( 'location, `' + location + '`' );  // not relevant to _annex_-hay-aeon
    var location_prefix = (location || "").slice(0, 3).toUpperCase();
    console.log( 'location_prefix, `' + location_prefix + '`' );  // not relevant to _annex_-hay-aeon

    /* JCB Aeon link */
    if (location_prefix == "JCB") {
      url = jcbRequestFullLink(bibData.id, bibData.title, bibData.author, bibData.publisher, item.call_number);
      html = '<a href="' + url + '">request-access</a>';
      // console.log( 'html, ```' + html + '```' );
      row.find(".jcb_url").html(html);
    }

    /* Hay Aeon link (i.e. "request access")
       - location `HMCF` appears as `HAY MICROFLM`` (yes, with that spelling)
       - location `HJH` appears as `HAY JOHN-HAY`
       - `isValidHayAeonLocation()` set in `application.js`
       */
    // TODO: _possible_ change from hay google-doc: use item.location-codes `arcms` or `hms`
    if ( location_prefix == "HAY" || location == "HMCF" || location == "HJH" ) {
      console.log( 'HAY-ish prefix found.' )
      if ( isValidHayAeonLocation(location) == true ) {
        console.log( 'valid hay-aeon location found' )
        url = hayAeonFullLink(bibData.id, bibData.title, bibData.author, bibData.publisher, item.call_number, location);
        html = '&nbsp &nbsp <a href="' + url + '">request-access</a>';
        row.find(".hay_aeon_url").html(html);
      }
    }

    /* Annex Hay Aeon Link (i.e. "request access") */

    // qhs = annex hay
    // if ((item.location_code == "qhs") && (status == "AVAILABLE")) {
    //   if ( scope.getFormat() != "Archives/Manuscripts" ) {
    //     url = easyrequestHayFullLink(bibData.id, barcode, bibData.title, bibData.author, bibData.publisher, item.call_number, location);
    //     html = '&nbsp &nbsp <a href="' + url + '">request-access</a>';
    //     row.find(".annexhay_easyrequest_url").html(html);
    //   }
    // }

    if ( (item.location_code == "qhs") && (status == "AVAILABLE") && (item.call_number.toUpperCase().includes("RESTRICTED") == false) ) {
      url = easyrequestHayFullLink(bibData.id, barcode, bibData.title, bibData.author, bibData.publisher, item.call_number, location);
      html = '&nbsp &nbsp <a href="' + url + '">request-access</a>';
      row.find(".annexhay_easyrequest_url").html(html);
    }
  };


  scope.takeHomeLocations = function() {
    var locs = [];
    locs.push("ANNEX");
    locs.push("ORWIG");
    locs.push("ROCK");
    locs.push("ROCK (RESTRICTED CIRC)");
    locs.push("ROCK CHINESE");
    locs.push("ROCK CUTTER-K");
    locs.push("ROCK DIVERSIONS");
    locs.push("ROCK JAPANESE");
    locs.push("ROCK KOREAN");
    locs.push("ROCK STORAGE");
    locs.push("ROCK STORAGE CUTTER");
    locs.push("ROCK STORAGE STAR");
    locs.push("ROCK STORAGE TEXTBOOKS");
    locs.push("ROCK STORAGE THESES");
    locs.push("SCI");
    return locs;
  };


  scope.isTakeHomeLocation = function(location) {
    var i;
    var locs = scope.takeHomeLocations();
    for(i = 0; i < locs.length; i++) {
      if (location == locs[i]) {
        return true;
      }
    }
    return false;
  };


  scope.isAvailableStatus = function(status) {
    if ((status == "AVAILABLE") || (status == "NEW BOOKS") || (status == "ASK AT CIRC")) {
      return true;
    }
    return false;
  };


  scope.debugMessage = function(message) {
    var debug = josiahObject.getUrlParameter("debug");
    if (debug == "true") {
      $("#debugInfo").removeClass("hidden");
      $("#debugInfo").append("<p style='color:blue;'>" + message + "</p>");
    }
  };


  // =============================================
  //
  // Virtual Shelf functions
  //
  // =============================================
  scope.browseShelfUri = function(id, block, norm) {
    url = josiahRootUrl + "api/items/nearby?id=" + id;
    if (block) {
      url += "&block=" + block;
    }
    if (norm) {
      url += "&normalized=" + norm;
    }
    return url;
  };


  scope.browseStackUri = function(id) {
    return josiahRootUrl + "browse/" + id;
  };


  scope.scrollToBottomOfPage = function() {
    // scroll to bottom of the page
    // http://stackoverflow.com/a/10503637/446681
    $("html, body").animate({ scrollTop: $(document).height() }, 1000);
  };


  scope.loadNearbyItems = function(scroll) {
    var id = scope.getBibId();
    var url = scope.browseShelfUri(id, null, null);
    $.getJSON(url, function(data) {
      if (data.docs.length == 0) {
        $("#also-on-shelf").removeClass("hidden");
        $("#also-on-shelf-none").removeClass("hidden");
      } else {
        scope.addDebugInfoToDocs(data.docs);
        var i;
        for(i = 0; i < data.docs.length; i++) {
          data.docs[i].shelfrank = data.docs[i].id == id ? 50 : 15;
        }
        // Make a global object available for use as the user loads more data.
        // I don't like that I am referencing the internals of the stackviewObject
        // but this would do for now while I figure out a better way to load
        // data on demand.
        if (window.theStackViewObject == undefined) {
          window.theStackViewObject = $('#basic-stack').stackView({data: data, query: "test book", ribbon: ""}).data().stackviewObject;
        } else {
          var i;
          for(i = 0; i < data.docs.length; i++) {
            window.theStackViewObject.add(i, data.docs[i]);
          }
          var numItemsAdded = data.docs.length;
          for(i = 0; i < numItemsAdded; i++) {
            window.theStackViewObject.remove(numItemsAdded);
          }
        }
        scope.updateNearbyBounds(data.docs, true, true);
        $("#also-on-shelf").removeClass("hidden");
        $(".upstream").on("click", function() { scope.loadPrevNearbyItems(); });
        $(".downstream").on("click", function() { scope.loadNextNearbyItems(); });
        scope.clearResetButton();
      }

      if (scroll) {
        scope.scrollToBottomOfPage();
      }
    });
  };


  scope.loadPrevNearbyItems = function() {
    var id = $("#firstBook").text();
    var norm = $("#firstBookNorm").text();
    var url = scope.browseShelfUri(id, "prev", norm);
    $.getJSON(url, function(data) {
      scope.addDebugInfoToDocs(data.docs);
      scope.highlightCurrent(data.docs);
      var lastIndex = window.theStackViewObject.options.data.docs.length - 1;
      var i;
      for(i = 0; i < data.docs.length; i++) {
        window.theStackViewObject.remove(lastIndex);
        window.theStackViewObject.add(i, data.docs[i]);
      }
      scope.showResetButton();
      scope.updateNearbyBounds(data.docs, true, true);
    });
  };


  scope.loadNextNearbyItems = function() {
    var id = $("#lastBook").text();
    var norm = $("#lastBookNorm").text();
    var url = scope.browseShelfUri(id, "next", norm);
    $.getJSON(url, function(data) {
      scope.addDebugInfoToDocs(data.docs);
      scope.highlightCurrent(data.docs);
      var i;
      for(i = 0; i < data.docs.length; i++) {
        window.theStackViewObject.remove(0);
        window.theStackViewObject.add(data.docs[i]);
      }
      scope.showResetButton();
      scope.updateNearbyBounds(data.docs, true, true);
    });
  };


  // Save the Id and normalized call number at the top and/or bottom
  // of the stack. We use these values as our starting point when the
  // users wants to continue fetching records.
  scope.updateNearbyBounds = function(docs, prev, next) {
    if (docs.length == 0) {
      if (prev) {
        $("#firstBook").text("");
        $("#firstBookNorm").text("");
      }
      if (next) {
        $("#lastBook").text("");
        $("#lastBookNorm").text("");
      }
    } else {
      if (prev) {
        $("#firstBook").text(docs[0].id);
        $("#firstBookNorm").text(docs[0].normalized);
      }
      if (next) {
        $("#lastBook").text(docs[docs.length-1].id);
        $("#lastBookNorm").text(docs[docs.length-1].normalized);
      }
    }
  };


  scope.highlightCurrent = function(docs) {
    var currentId = scope.getBibId();
    var i;
    for(i = 0; i < docs.length; i++) {
      if (docs[i].id == currentId) {
        docs[i].shelfrank = 50;
        break;
      }
    }
  };


  scope.addDebugInfoToDocs = function(docs) {
    if (location.search.indexOf("verbose") == -1) {
      return;
    }
    var i;
    for(i = 0; i < docs.length; i++) {
      doc = docs[i];
      doc.title = doc.title + "<br/>" + doc.id + ": " + doc.callnumbers.toString();
    }
  };


  scope.showResetButton = function() {
    var href = '<a id="resetShelfLink" href="#" title="Show me the inital stack of books">reset</a>';
    var html = "<span>" + href + "</span>";
    $(".num-found").html(html);
    $("#resetShelfLink").on("click", function() { scope.loadNearbyItems(false); });
  };


  scope.clearResetButton = function() {
    var html = '<span>&nbsp;</span>';
    $(".num-found").html(html);
  };


  scope.addVirtualShelfLinks = function(bib_id) {
    // Add "More Like This" option to tools section
    var link1 = '<li><a id="moreLikeThisLink" href="#">More Like This</a>';
    $("div.panel-body>ul.nav").append(link1);
    $("#moreLikeThisLink").on("click", function() { scope.loadNearbyItems(true); });

    // Add "Browse the stacks" option to tools section
    var link2 = '<li><a href="' + scope.browseStackUri(bib_id) + '" target="_blank">Browse the Stacks</a>';
    $("div.panel-body>ul.nav").append(link2);
  };


  // Execute our code
  scope.Init();

}); // $(document).ready(function() {

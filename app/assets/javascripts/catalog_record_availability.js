// JavaScript functions for individual catalog records.
// Loaded by `app/views/catalog/show.html.erb`.
//
// Global variables:
//  josiahRootUrl - defined in shared/_header_navbar.html.erb
//  josiahObject - defined in app/assets/javascripts/application.js,
//                 populated in app/views/catalog/_show_default.html.erb
//
$(document).ready(function() {
  catalogRecordAvailabilityInit();
});

function catalogRecordAvailabilityInit() {
  var req, apiUrl, limit;

  addOcraLink(josiahObject.bibData.id);
  addBookServicesLink();
  addVirtualShelfLinks(josiahObject.bibData.id);

  if (josiahObject.availabilityService) {
    apiUrl = josiahObject.availabilityService + josiahObject.bibData.id + "/?callback=?";
    limit = josiahObject.getUrlParameter("limit");
    if (limit == "false") {
      apiUrl += "&limit=false";
    }
  }

  if (apiUrl && josiahObject.bibData.showAvailability) {
    // We are using .ajax() rather than .getJSON() here to be able
    // to handle errors (https://stackoverflow.com/a/5121811/446681)
    // The timeout value is required for the error() function to be called!
    req = $.ajax({url: apiUrl, dataType: "jsonp", timeout: 5000});
    req.success(addAvailability);
    req.error(errAvailability);
  } else {
    showAvailability(true);
    showAeon();
    debugMessage("Skipped call to Availability API");
  }

  if (location.search.indexOf("nearby") > -1) {
    loadNearbyItems(false);
  }

  debugMessage("BIB record multi: " + josiahObject.bibData.itemsMultiType)
}


function getItemById(id) {
  var i;
  if (id == null || id == "") {
    return null;
  }
  for(i = 0; i < josiahObject.itemsData.length; i++) {
    if (josiahObject.itemsData[i].id == id) {
      return josiahObject.itemsData[i];
    }
  }
  return null;
}


function getItemByBarcode(barcode) {
  var i;
  if (barcode == null || barcode == "") {
    return null;
  }
  for(i = 0; i < josiahObject.itemsData.length; i++) {
    if (josiahObject.itemsData[i].barcode == barcode) {
      return josiahObject.itemsData[i];
    }
  }
  return null;
}


function getItemByCallnumber(avCallnumber) {
  var i, candidates, marcCallnumber;
  if (avCallnumber == null || avCallnumber == "") {
    return null;
  }

  for(i = 0; i < josiahObject.itemsData.length; i++) {
    marcCallnumber = josiahObject.itemsData[i].call_number;
    if (marcCallnumber != null && marcCallnumber == avCallnumber) {
      // we found an exact match.
      return josiahObject.itemsData[i];
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
  for(i = 0; i < josiahObject.itemsData.length; i++) {
    marcCallnumber = josiahObject.itemsData[i].call_number;
    if (marcCallnumber != null && avCallnumber.indexOf(marcCallnumber) != -1) {
      candidates.push(josiahObject.itemsData[i]);
    }
  }
  if (candidates.length == 1) {
    // yay! we got a single match.
    return candidates[0];
  }
  return null;
}


function getBibId() {
  return josiahObject.bibData.id;
}


function getTitle() {
  return josiahObject.bibData.title;
}


function getFormat() {
  return josiahObject.bibData.format;
}


function getAuthor() {
  return josiahObject.bibData.author;
}


function getPublisher() {
  josiahObject.bibData.publisher;
}


function addOcraLink(bib_id) {
  var ocraUrl = "https://library.brown.edu/reserves/cr/ocrify/?bibnum=" + bib_id;
  var helpInfo = "Staff and Teaching Assistants can reserve this item in OCRA for courses they teach.";
  var link = '<li><a href="' + ocraUrl + '" title="' + helpInfo + '" target="_blank">Add to OCRA</a>';
  $("div.panel-body>ul.nav").append(link);
}


function addBookServicesLink() {
  // hidden by default
  var li = '<li id="book_services_link" class="hidden">';
  var helpInfo = "Request this item to be paged (Faculty and Grad/Med students only)";
  var a = '<a href="' + josiahObject.bibData.bookServicesUrl + '" title="' + helpInfo + '" target="_blank">Request This</a>';
  var html = li + a;
  $("div.panel-body>ul.nav").append(html);
}


function addAvailability(availabilityResponse) {
  // Realtime status of items (and other item specific information)
  _.each(availabilityResponse.items, function(avItem) {
    updateItemInfo(avItem);
  });

  if (availabilityResponse.has_more == true) {
    $("#show_more_items").removeClass("hidden");
    showAvailability(false);
  } else {
    showAvailability(true);
  }

  if (availabilityResponse.requestable) {
    $("#book_services_link").removeClass("hidden");
  };

  showEasyBorrowBib(availabilityResponse.items);
}


function errAvailability() {
  // show whatever we have from the MARC data already on the HTML
  debugMessage("Availability API error, using MARC data instead");
  showAvailability(true);
  showAeon();
}


function showAvailability(all) {
  var i;
  var limit = josiahObject.getUrlParameter("limit");
  var items = $(".bib_item");
  for (i = 0; i < items.length; i++) {
    if (all || i < 10) {
      $(items[i]).removeClass("hidden");
    }
  }
}


function showAeon() {
  var i, item, row;
  for(i = 0; i < josiahObject.itemsData.length; i++) {
    item = josiahObject.itemsData[i];
    row = rowForItem(item);
    updateItemAeonLinks(row, item);
  }
}


function showEasyBorrowBib(avItems) {
  var i
  var hasAvailableItems = false;
  var hasEasyBorrowItems = false;
  var allowEasyBorrow = (josiahObject.bibData.itemsMultiType == "copy" || josiahObject.bibData.itemsMultiType == "single");

  if (!josiahObject.availabilityEZB) {
    console.log("ezb bib: disabled");
    return;
  } else if (!allowEasyBorrow) {
    console.log("ezb bib: not applicable");
    return;
  }

  for (i = 0; i < avItems.length; i++) {
    if (isAvailableStatus(avItems[i]["status"])) {
      hasAvailableItems = true;
    } else if (isTakeHomeLocation(avItems[i]["location"])) {
      hasEasyBorrowItems = true;
    }
  }

  if (!hasAvailableItems && hasEasyBorrowItems) {
    console.log("ezb bib: yes");
    $("#request-copy-ezb").removeClass("hidden");
  } else {
    console.log("ezb bib: no (av:" + hasAvailableItems + ", ezb:" + hasEasyBorrowItems + ")");
  }
}


function rowForItem(item) {
  return $("#item_" + item.id);
}


// Updates item information (already on the page) with the
// extra information that we got from the Availability service.
function updateItemInfo(avItem) {
  var item, barcode, callnumber, itemRow;

  barcode = avItem['barcode'] || "";
  callnumber = avItem['callnumber'] || "";

  item = getItemByBarcode(barcode);
  if (item == null) {
    item = getItemByCallnumber(callnumber);
    if (item == null) {
      debugMessage("ERROR: item (" + barcode + "/" + callnumber + ") not found in MARC item data");
      return;
    }
  }

  itemRow = rowForItem(item);

  if (item.call_number != callnumber) {
    // The call number in the MARC data is different from the one the
    // availability API returned. Prefer the one from the availability API.
    itemRow.find(".callnumber").html(callnumber);
    debugMessage("WARN: call number mismatch for barcode " + barcode + ": <b>" + item.call_number  + "</b> vs <b>" + callnumber + "</b>");
  }

  updateItemLocation(itemRow, avItem);
  updateItemStatus(itemRow, avItem, item.volume);
  updateItemScanStatus(itemRow, avItem, barcode);
  updateItemAeonLinks(itemRow, item);
}


function updateItemLocation(row, avItem) {
  var floor, aisle, mapText, mapUrl, html;

  if (avItem['location']) {
    row.find(".location").html(avItem['location']);
  }

  if (avItem['shelf'] && avItem['shelf']['floor'] && avItem['shelf']['aisle']) {
    floor = avItem['shelf']['floor'];
    aisle = avItem['shelf']['aisle'];
    mapText = "Level " + floor + ", Aisle " + aisle;
    if (avItem['map']) {
      mapUrl = avItem['map'] + '&title=' + getTitle();
      html = "-- <a href=" + mapUrl + ">" + mapText + "</a>";
    } else {
      html = "-- " + mapText;
    }
    row.find(".location_map").html(html);
  }
}


function updateItemStatus(row, avItem, volume) {
  var status, location, offerEZB, url, text, tooltip, html;
  status = avItem["status"];
  if (status) {
    row.find(".status").html(status);
    location = avItem["location"];
    offerEZB = josiahObject.availabilityEZB && josiahObject.bibData.itemsMultiType == "volume" &&
      !isAvailableStatus(status) && isTakeHomeLocation(location);
    if (offerEZB) {
      // Allow the user to request this volume via easyBorrow.
      url = josiahObject.bibData.easyBorrowUrl;
      if (volume != "") {
          url += "&volume=" + volume;
      }
      text = "Request this volume via EasyBorrow";
      tooltip = "Our copy is not available at the moment, but we can try get it for you from other libraries";
      html = '<br/><a href="' + url + '" title="' + tooltip + '" target="_blank">' + text + '</a>';
      row.find(".ezb_volume_url").html(html);
    }
  }
}


function updateItemScanStatus(row, avItem, barcode) {
  var scanLink, itemLink, html;
  // TODO: move the status check inside canScanItem()
  //       once we fix the results page.
  if (avItem["status"] == "AVAILABLE") {
    if (canScanItem(avItem['location'], josiahObject.bibData.format)) {
      scanLink = '<a href="' + easyScanFullLink(avItem['scan'], josiahObject.bibData.id, josiahObject.bibData.title) + '">scan</a>';
      itemLink = '<a href="' + itemRequestFullLink(barcode, josiahObject.bibData.id) + '">item</a>';
      html = scanLink + " | " + itemLink;
      row.find(".scan").html(html);
    }
  }
}


function updateItemAeonLinks(row, item) {
  var url, html;
  var location = item.location_name;
  var location_prefix = (location || "").slice(0, 3).toUpperCase();

  // JCB Aeon link
  if (location_prefix == "JCB") {
    url = jcbRequestFullLink(josiahObject.bibData.id, josiahObject.bibData.title, josiahObject.bibData.author, josiahObject.bibData.publisher, item.call_number);
    html = '<a href="' + url + '">request-access</a>';
    row.find(".jcb_url").html(html);
  }

  // Hay Aeon link
  if (location_prefix == "HAY") {
    if (isValidHayAeonLocation(location) == true) {
      url = hayAeonFullLink(josiahObject.bibData.id, josiahObject.bibData.title, josiahObject.bibData.author, josiahObject.bibData.publisher, item.call_number, location);
      html = '<a href="' + url + '">request-access</a>';
      row.find(".hay_aeon_url").html(html);
    }
  }
}


function takeHomeLocations() {
  var locs = [];
  locs.push("ANNEX");
  // locs.push("ANNEX ***"); ????
  // locs.push("ONLINE");, <== remove
  // locs.push("ONLINE BOOK"); <== remove
  // locs.push("ORWIG STORAGE");  <== remove
  // locs.push("ROCK STORAGE FARMINGTON");  <==remove
  // locs.push("SCI THESES"); <==remove
  locs.push("ORWIG");
  locs.push("ROCK");
  locs.push("ROCK (RESTRICTED CIRC)");  // <== new
  locs.push("ROCK CHINESE");
  locs.push("ROCK CUTTER-K");           // <== new
  locs.push("ROCK DIVERSIONS");         // <== new
  locs.push("ROCK JAPANESE");
  locs.push("ROCK KOREAN");
  locs.push("ROCK STORAGE");
  locs.push("ROCK STORAGE CUTTER");
  locs.push("ROCK STORAGE STAR");
  locs.push("ROCK STORAGE TEXTBOOKS");
  locs.push("ROCK STORAGE THESES");
  locs.push("SCI");
  return locs;
}


function isTakeHomeLocation(location) {
  var i;
  var locs = takeHomeLocations();
  for(i = 0; i < locs.length; i++) {
    if (location == locs[i]) {
      return true;
    }
  }
  return false;
}


function isAvailableStatus(status) {
  if ((status == "AVAILABLE") || (status == "NEW BOOKS") || (status == "ASK AT CIRC")) {
    return true;
  }
  return false;
}


function debugMessage(message) {
  var debug = josiahObject.getUrlParameter("debug");
  if (debug == "true") {
    $("#debugInfo").removeClass("hidden");
    $("#debugInfo").append("<p style='color:blue;'>" + message + "</p>");
  }
}


// =============================================
//
// Virtual Shelf functions
//
// =============================================
function browseShelfUri(id, block, norm) {
  url = josiahRootUrl + "api/items/nearby?id=" + id;
  if (block) {
    url += "&block=" + block;
  }
  if (norm) {
    url += "&normalized=" + norm;
  }
  return url;
}


function browseStackUri(id) {
  return josiahRootUrl + "browse/" + id;
}


function scrollToBottomOfPage() {
  // scroll to bottom of the page
  // http://stackoverflow.com/a/10503637/446681
  $("html, body").animate({ scrollTop: $(document).height() }, 1000);
}


function loadNearbyItems(scroll) {
  var id = getBibId();
  var url = browseShelfUri(id, null, null);
  $.getJSON(url, function(data) {
    if (data.docs.length == 0) {
      $("#also-on-shelf").removeClass("hidden");
      $("#also-on-shelf-none").removeClass("hidden");
    } else {
      addDebugInfoToDocs(data.docs);
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
      updateNearbyBounds(data.docs, true, true);
      $("#also-on-shelf").removeClass("hidden");
      $(".upstream").on("click", function() { loadPrevNearbyItems(); });
      $(".downstream").on("click", function() { loadNextNearbyItems(); });
      clearResetButton();
    }

    if (scroll) {
      scrollToBottomOfPage();
    }
  });
}


function loadPrevNearbyItems() {
  var id = $("#firstBook").text();
  var norm = $("#firstBookNorm").text();
  var url = browseShelfUri(id, "prev", norm);
  $.getJSON(url, function(data) {
    addDebugInfoToDocs(data.docs);
    highlightCurrent(data.docs);
    var lastIndex = window.theStackViewObject.options.data.docs.length - 1;
    var i;
    for(i = 0; i < data.docs.length; i++) {
      window.theStackViewObject.remove(lastIndex);
      window.theStackViewObject.add(i, data.docs[i]);
    }
    showResetButton();
    updateNearbyBounds(data.docs, true, true);
  });
}


function loadNextNearbyItems() {
  var id = $("#lastBook").text();
  var norm = $("#lastBookNorm").text();
  var url = browseShelfUri(id, "next", norm);
  $.getJSON(url, function(data) {
    addDebugInfoToDocs(data.docs);
    highlightCurrent(data.docs);
    var i;
    for(i = 0; i < data.docs.length; i++) {
      window.theStackViewObject.remove(0);
      window.theStackViewObject.add(data.docs[i]);
    }
    showResetButton();
    updateNearbyBounds(data.docs, true, true);
  });
}


// Save the Id and normalized call number at the top and/or bottom
// of the stack. We use these values as our starting point when the
// users wants to continue fetching records.
function updateNearbyBounds(docs, prev, next) {
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
}


function highlightCurrent(docs) {
  var currentId = getBibId();
  var i;
  for(i = 0; i < docs.length; i++) {
    if (docs[i].id == currentId) {
      docs[i].shelfrank = 50;
      break;
    }
  }
}


function addDebugInfoToDocs(docs) {
  if (location.search.indexOf("verbose") == -1) {
    return;
  }
  var i;
  for(i = 0; i < docs.length; i++) {
    doc = docs[i];
    doc.title = doc.title + "<br/>" + doc.id + ": " + doc.callnumbers.toString();
  }
}


function showResetButton() {
  var href = '<a onClick="loadNearbyItems(false); return false;" ' +
    'href="#" title="Show me the inital stack of books">reset</a>';
  var html = "<span>" + href + "</span>";
  $(".num-found").html(html);
}


function clearResetButton() {
  var html = '<span>&nbsp;</span>';
  $(".num-found").html(html);
}


function addVirtualShelfLinks(bib_id) {
  // Add "More Like This" option to tools section
  var link1 = '<li><a onclick="loadNearbyItems(true); return false;" href="#">More Like This</a>';
  $("div.panel-body>ul.nav").append(link1);

  // Add "Browse the stacks" option to tools section
  var link2 = '<li><a href="' + browseStackUri(bib_id) + '" target="_blank">Browse the Stacks</a>';
  $("div.panel-body>ul.nav").append(link2);
}

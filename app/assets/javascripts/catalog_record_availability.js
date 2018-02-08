// JavaScript functions for individual catalog records.
// Loaded by `app/views/catalog/show.html.erb`.
//
// Global variables (defined in app/views/catalog/show.html.erb):
//      availabilityService
//      availabilityEZB
//      bibData
//      itemData
//      josiahRootUrl   (defined in shared/_header_navbar.html.erb)
//
$(document).ready(function() {
  var req, apiUrl, limit;

  addOcraLink(bibData.id);
  addBookServicesLink();
  addVirtualShelfLinks(bibData.id);

  if (availabilityService) {
    apiUrl = availabilityService + bibData.id + "/?callback=?";
    limit = getUrlParameter("limit");
    if (limit == "false") {
      apiUrl += "&limit=false";
    }
  }

  if (apiUrl && bibData.showAvailability) {
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

  debugMessage("BIB record multi: " + bibData.itemsMultiType)
});


function getItemById(id) {
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
}


function getItemByBarcode(barcode) {
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
}


function getItemByCallnumber(avCallnumber) {
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
}


function getBibId() {
  return bibData.id;
}


function getTitle() {
  return bibData.title;
}


function getFormat() {
  return bibData.format;
}


function getAuthor() {
  return bibData.author;
}


function getPublisher() {
  bibData.publisher;
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
  var helpInfo = "Faculty and Grad/Med students can request this book to be paged for you.";
  var a = '<a href="' + bibData.bookServicesUrl + '" title="' + helpInfo + '" target="_blank">Request This</a>';
  var html = li + a;
  $("div.panel-body>ul.nav").append(html);
}


function addAvailability(availabilityResponse) {
  var i;
  var someAvailable = false;

  for (i = 0; i < availabilityResponse.items.length; i++) {
    if (availabilityResponse.items[i]['status'] == "AVAILABLE") {
      someAvailable = true;
      break
    }
  }

  // // TODO: remove this test code
  // if (bibData.id == "b1235490") {
  //   availabilityResponse.items[1]['status'] = "DUE XX/YY/ZZZZ";
  // }

  // Realtime status of items (and other item specific information)
  _.each(availabilityResponse.items, function(avItem) {
    updateItemInfo(avItem, availabilityResponse.requestable);
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

  showEasyBorrow(availabilityResponse.requestable, someAvailable);
}


function errAvailability() {
  // show whatever we have from the MARC data already on the HTML
  debugMessage("Availability API error, using MARC data instead");
  showAvailability(true);
  showAeon();
}


function showAvailability(all) {
  var i;
  var limit = getUrlParameter("limit");
  var items = $(".bib_item");
  for (i = 0; i < items.length; i++) {
    if (all || i < 10) {
      $(items[i]).removeClass("hidden");
    }
  }
}


function showAeon() {
  var i, item, row;
  for(i = 0; i < itemsData.length; i++) {
    item = itemsData[i];
    row = rowForItem(item);
    updateItemAeonLinks(row, item);
  }
}


function showEasyBorrow(requestable, someAvailable) {
  var allowEasyBorrow = false;
  if (!availabilityEZB) {
    return;
  }
  if (requestable) {
    // If the bib record is requestable and there are no copies
    // available allow the user to request it via easyBorrow.
    //
    // A downside of this approach is that items that are lost are not
    // requestable and therefore we are not allowing the user to use
    // easyBorrow in those cases. However, allowing easyBorrow for non
    // requestable items allows the user to requests things that are
    // not available via easyBorrow (e.g. items for use in library).
    // In a future version we could expand the logic to be more specific
    // on what status should allow easyBorrow. For now this is better than
    // not allowing easyBorrow at all.
    if (someAvailable == false) {
      allowEasyBorrow = (bibData.itemsMultiType == "copy" || bibData.itemsMultiType == "single")
    }
  }

  if (allowEasyBorrow) {
    $("#request-copy-ezb").removeClass("hidden");
  }
}


function rowForItem(item) {
  return $("#item_" + item.id);
}


// Updates item information (already on the page) with the
// extra information that we got from the Availability service.
function updateItemInfo(avItem, requestable) {
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
  updateItemStatus(itemRow, avItem, requestable, item.volume);
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


function updateItemStatus(row, avItem, requestable, volume) {
  var status, url, text, tooltip, html;
  status = avItem['status'];
  if (status) {
    row.find(".status").html(status);
    if (availabilityEZB && requestable && bibData.itemsMultiType == "volume" && status != "AVAILABLE") {
      // Allow the user to request this volume via easyBorrow.
      url = bibData.easyBorrowUrl;
      if (volume != "") {
          url += "&volume=" + volume;
      }
      text = "Request this volume";
      tooltip = "Our copy is not available at the moment, but we can try get it for you from other libraries";
      html = '<a href="' + url + '" title="' + tooltip + '" target="_blank">' + text + '</a>';
      row.find(".ezb_volume_url").html(html);
    }

  }
}


function updateItemScanStatus(row, avItem, barcode) {
  var scanLink, itemLink, html;
  if (canScanItem(avItem['location'], bibData.format)) {
    scanLink = '<a href="' + easyScanFullLink(avItem['scan'], bibData.id, bibData.title) + '">scan</a>';
    itemLink = '<a href="' + itemRequestFullLink(barcode, bibData.id) + '">item</a>';
    html = scanLink + " | " + itemLink;
    row.find(".scan").html(html);
  }
}


function updateItemAeonLinks(row, item) {
  var url, html;
  var location = item.location_name;
  var location_prefix = (location || "").slice(0, 3).toUpperCase();

  // JCB Aeon link
  if (location_prefix == "JCB") {
    url = jcbRequestFullLink(bibData.id, bibData.title, bibData.author, bibData.publisher, item.call_number);
    html = '<a href="' + url + '">request-access</a>';
    row.find(".jcb_url").html(html);
  }

  // Hay Aeon link
  if (location_prefix == "HAY") {
    if (isValidHayAeonLocation(location) == true) {
      url = hayAeonFullLink(bibData.id, bibData.title, bibData.author, bibData.publisher, item.call_number, location);
      html = '<a href="' + url + '">request-access</a>';
      row.find(".hay_aeon_url").html(html);
    }
  }
}


function debugMessage(message) {
  var debug = getUrlParameter("debug");
  if (debug == "true") {
    $("#debugInfo").removeClass("hidden");
    $("#debugInfo").append("<p style='color:blue;'>" + message + "</p>");
  }
}


function getUrlParameter(sParam) {
  var sPageURL = window.location.search.substring(1);
  var sURLVariables = sPageURL.split('&');
  for (var i = 0; i < sURLVariables.length; i++) {
    var sParameterName = sURLVariables[i].split('=');
    if (sParameterName[0] == sParam) {
      return sParameterName[1];
    }
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

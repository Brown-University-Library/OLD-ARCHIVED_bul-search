// JavaScript functions for virtual shelf full page.
// Loaded by `app/views/browse/index.html.erb`.
$(document).ready(function(){
  var id = $("#initialID").text();
  var verbose = (location.search.indexOf("verbose") != -1) ? "&verbose" : "";

  // josiahRootUrl is defined in app/views/browse/index.html.erb
  var url = josiahRootUrl + "api/items/shelf_items?id=" + id + verbose;
  var options = {url: url, search_type: "loc_sort_order", ribbon: ""};
  $('#basic-stack').stackView(options);

  // initial size
  resizeStack();

  // make sure it resizes as the window resizes
  $(window).resize(function() { resizeStack(); });

  // Load the details for the current item
  var jsonUri = josiahRootUrl + "api/items/shelf_item/" + id;
  $.getJSON(jsonUri, showPreview);

  // Wire up the click event on all items to load the details
  // (the default behavior is to go the item in the catalog)
  //
  // Note: using (#stack-item + a) as the selector
  // (instead of body + li>a) didn't work, I am not sure why.
  $('body').on('click', 'li>a', function(e) {
    var _this = $(this);
    var jsonUri = _this.attr("href").replace("/catalog/", "/api/items/shelf_item/");
    $('.active-item').removeClass('active-item');
    _this.parent().addClass('active-item');
    $.getJSON(jsonUri, showPreview);
    return false;
  });
});


function resizeStack() {
  var stackheight = $(window).height();
  $('#basic-stack').css('height', stackheight);
  // Set the stack-items width a tad narrower than the width of
  // the basic-stack div so that the scroll bars are not visible.
  //
  // Setting "overflow: hidden" on stack-items does the same
  // thing but has the disadvantage that it disables scrolling
  // alltogether :(
  var wrapperWidth = $('#basic-stack').width();
  $('.stack-items').width(wrapperWidth-10);
}


function showPreview(doc) {
  var uri = josiahRootUrl + "catalog/" + doc.id;
  $("#previewTitle").html(doc.title);
  $("#previewAuthor").html(doc.author);
  $("#previewImprint").html(doc.imprint);

  $("#previewLink").attr("href", uri)
  $("#previewLinkImage").attr("href", uri)

  $("#previewPanel").removeClass("hidden");

  var keys = bookCoverKeys(doc.isbn_t, doc.oclc_t);
  loadBookCover(keys);
}


function bookCoverKeys(isbn_t, oclt_t) {
  var i;
  var keys = "";
  if (isbn_t != undefined) {
    for(i = 0; i < isbn_t.length; i++) {
      keys += "ISBN" + isbn_t[i] + ",";
    }
  }
  if (oclt_t != undefined) {
    for(i = 0; i < oclt_t.length; i++) {
      keys += "OCLC" + oclt_t[i] + ",";
    }
  }
  return keys;
}


function loadBookCover(keys) {
  var booksApiUrl = "https://books.google.com/books?jscmd=viewapi&bibkeys=" + keys;
  loadingBookCover();
  $.ajax({
    type: 'GET',
    url: booksApiUrl,
    async: false,
    contentType: "application/json",
    dataType: 'jsonp',
    success: function(json) {
      var i, key, obj, thumbUrl;
      var found = false;
      var keys = Object.keys(json);
      for(i = 0; i < keys.length; i++) {
        key = keys[i];
        obj = json[key];
        if (obj.thumbnail_url != undefined) {
          thumbUrl = obj.thumbnail_url.replace(/zoom=5/, 'zoom=1');
          thumbUrl = thumbUrl.replace(/&?edge=curl/, '');
          $("#previewImage").attr("alt", "Book cover");
          $("#previewImage").attr("src", thumbUrl);
          found = true;
          break;
        }
      }
      if (!found) {
        noBookCover();
      }
    },
    error: function(e) {
      console.log(e);
      noBookCover();
    }
  });
}


function noBookCover() {
  var image = $("#previewImageNone").attr("src");
  $("#previewImage").attr("alt", "No book cover available");
  $("#previewImage").attr("src", image);
}


function loadingBookCover() {
  var image = $("#previewImageLoading").attr("src");
  $("#previewImage").attr("alt", "Loading book cover");
  $("#previewImage").attr("src", image);
}

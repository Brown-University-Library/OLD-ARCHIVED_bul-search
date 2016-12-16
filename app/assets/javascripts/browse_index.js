// JavaScript functions for individual catalog records.
// Loaded by `app/views/browse/index.html.erb`.
$(document).ready(function(){
  var id = $("#initialID").text();
  var verbose = (location.search.indexOf("verbose") != -1) ? "&verbose" : "";
  var stackheight;

  // josiahRootUrl is defined in shared/_header_navbar.html.erb
  var url = josiahRootUrl + "api/items/shelf_items?id=" + id + verbose;
  var options = {url: url, search_type: "loc_sort_order", ribbon: ""};
  $('#basic-stack').stackView(options);

  // initial size
  stackheight = $(window).height();
  $('#basic-stack').css('height', stackheight);
  $('#stack-view').css('height', stackheight);

  // make sure it resizes as the window resizes
  $(window).resize(function() {
		var stackheight = $(window).height();
		$('#basic-stack').css('height', stackheight);
    $('#stack-view').css('height', stackheight);
	});

  // Load the details for the current item
  var jsonUri = josiahRootUrl + "catalog/" + id + ".json";
  $.getJSON(jsonUri, showPreview);

  // Wire up the click event on all items to load the details
  // (the default behavior is to go the item in the catalog)
  //
  // Note: using (#stack-item + a) as the selector
  // (instead of body + li>a) didn't work, I am not sure why.
  $('body').on('click', 'li>a', function(e) {
    var _this = $(this);
    var jsonUri = _this.attr("href") + ".json";
    $('.active-item').removeClass('active-item');
    _this.parent().addClass('active-item');
    $.getJSON(jsonUri, showPreview);
    return false;
  });
});

function showPreview(data) {
  // TODO: handle undefined properties
  var doc = data.response.document;
  var uri = josiahRootUrl + "catalog/" + doc.id;
  $("#previewTitle").html(doc.title_display);
  $("#previewAuthor").html(doc.author_display);
  $("#previewPubDate").html(doc.pub_date[0]);
  $("#previewFormat").html(doc.format);
  // $("#previewIsbn").html(doc.isbn_t.toString());
  // $("#previewCallnumbers").html(doc.callnumber_t.toString());
  $("#previewPanel").removeClass("hidden");

  $("#previewLink").attr("href", uri)
  $("#previewLinkImage").attr("href", uri)

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
      var i, key, obj;
      var found = false;
      var keys = Object.keys(json);
      for(i = 0; i < keys.length; i++) {
        key = keys[i];
        obj = json[key];
        if (obj.thumbnail_url != undefined) {
          $("#previewImage").attr("alt", "Book cover");
          $("#previewImage").attr("src", obj.thumbnail_url);
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

// JavaScript functions for virtual shelf full page.
// Loaded by `app/views/browse/index.html.erb`.
$(document).ready(function() {
  var scope = {};
  var josiahRootUrl = window.josiahRootUrl; // defined in app/views/browse/index.html.erb

  scope.Init = function() {
    var id = $("#initialID").text();
    var verbose = (location.search.indexOf("verbose") != -1) ? "&verbose" : "";

    var url = josiahRootUrl + "api/items/shelf_items?id=" + id + verbose;
    var options = {url: url, search_type: "loc_sort_order", ribbon: ""};
    $('#basic-stack').stackView(options);

    // initial size
    scope.resizeStack();

    // make sure it resizes as the window resizes
    $(window).resize(function() { scope.resizeStack(); });

    // Load the details for the current item
    var jsonUri = josiahRootUrl + "api/items/shelf_item/" + id;
    $.getJSON(jsonUri, scope.showPreview);

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
      $.getJSON(jsonUri, scope.showPreview);
      return false;
    });
  }


  scope.resizeStack = function() {
    var stackheight = $(window).height();
    $('#basic-stack').css('height', stackheight);
    // Set the stack-items width a tad narrower than the width of
    // the basic-stack div so that the scroll bars are not visible.
    //
    // Setting "overflow: hidden" on stack-items does the same
    // thing but has the disadvantage that it disables scrolling
    // altogether :(
    var wrapperWidth = $('#basic-stack').width();
    $('.stack-items').width(wrapperWidth-10);
  }


  scope.showPreview = function(doc) {
    var uri = josiahRootUrl + "catalog/" + doc.id;
    $("#previewTitle").html(doc.title);
    $("#previewAuthor").html(doc.author);
    $("#previewImprint").html(doc.imprint);

    $("#previewLink").attr("href", uri)
    $("#previewLinkImage").attr("href", uri)

    $("#previewPanel").removeClass("hidden");

    var keys = scope.bookCoverKeys(doc.isbns, doc.oclcs);
    scope.loadBookCover(keys);
  }


  scope.bookCoverKeys = function(isbns, oclts) {
    var i;
    var keys = "";
    if (isbns != undefined) {
      for(i = 0; i < isbns.length; i++) {
        keys += "ISBN" + isbns[i] + ",";
      }
    }
    if (oclts != undefined) {
      for(i = 0; i < oclts.length; i++) {
        keys += "OCLC" + oclts[i] + ",";
      }
    }
    return keys;
  }


  scope.loadBookCover = function(keys) {
    var booksApiUrl = "https://books.google.com/books?jscmd=viewapi&bibkeys=" + keys;
    scope.loadingBookCover();
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
          scope.noBookCover();
        }
      },
      error: function(e) {
        console.log(e);
        scope.noBookCover();
      }
    });
  }


  scope.noBookCover = function() {
    var image = $("#previewImageNone").attr("src");
    $("#previewImage").attr("alt", "No book cover available");
    $("#previewImage").attr("src", image);
  }


  scope.loadingBookCover= function() {
    var image = $("#previewImageLoading").attr("src");
    $("#previewImage").attr("alt", "Loading book cover");
    $("#previewImage").attr("src", image);
  }

  // Execute our code
  scope.Init();

}); // $(document).ready(function() {

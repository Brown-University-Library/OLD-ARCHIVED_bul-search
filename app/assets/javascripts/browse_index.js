// JavaScript functions for individual catalog records.
// Loaded by `app/views/browse/index.html.erb`.
$(document).ready(function(){
  var id = $("#initialID").text();
  var verbose = (location.search.indexOf("verbose") != -1) ? "&verbose" : "";
  var stackheight;

  // josiahRootUrl is defined in shared/_header_navbar.html.erb
  var url = josiahRootUrl + "api/items/shelf_items?id=" + id + verbose;
  var options = {url: url, search_type: "loc_sort_order", ribbon: ""};
  window.theStackViewObject = $('#basic-stack').stackView(options).data().stackviewObject;

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

  // TODO: using (#stack-item + a) as the selector (instead of body + li>a)
  // didn't work, I am not sure why.
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
  $("#previewTitle").html(data.response.document.id);
  $("#previewAuthor").html("<p>the author</p>");
  $("#previewPanel").removeClass("hidden");

}

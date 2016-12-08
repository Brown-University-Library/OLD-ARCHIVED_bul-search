// JavaScript functions for individual catalog records.
// Loaded by `app/views/browse/index.html.erb`.
$(document).ready(function(){
  var id = $("#initialID").text();
  var verbose = (location.search.indexOf("verbose") != -1) ? "&verbose" : "";
  var stackheight = $(window).height();

	$(window).resize(function() {
		stackheight = $(window).height();
		$('#basic-stack').css('height', stackheight);
    $('#stack-view').css('height', stackheight);
	});

  // josiahRootUrl is defined in shared/_header_navbar.html.erb
  var url = josiahRootUrl + "api/items/shelf_items?id=" + id + verbose;
  var options = {url: url, query: "", ribbon: ""};
  window.theStackViewObject = $('#basic-stack').stackView(options).data().stackviewObject;

  $('#basic-stack').css('height', stackheight);
  $('#stack-view').css('height', stackheight);
});

Blacklight.onLoad(function(){
   $("button.info-box").popover({
      trigger: 'hover',
      placement: 'auto',
      container: 'body'
   });
   $('[data-toggle="popover"]').popover()
});
Blacklight.onLoad(function(){
   $("button.info-box").popover({
      trigger: 'hover',
      placement: 'auto'
   });
   $('[data-toggle="popover"]').popover()
});
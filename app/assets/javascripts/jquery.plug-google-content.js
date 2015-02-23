(function($) {
  /*
    Adapted from Stanford's SearchWorks: https://github.com/sul-dlss/SearchWorks/blob/f110b1ae46781ebca008c8289d17378eec9dc05f/app/assets/javascripts/jquery.plug-google-content.js
    jQuery plugin to render Google book covers for image elements

      Usage: $(selector).renderGoogleBookCovers();

    This plugin :
      - collects all 'img.cover-image' elements and batches them
      - using ISBN, OCLC & LCCN value(s) of image elements inside each batch,
        Google cover images are added using Google Books API
  */

  $.fn.plugGoogleBookContent = function() {
    var $parent,
        booksPerAjaxCall = 25,
        booksApiUrl = '//books.google.com/books?jscmd=viewapi&bibkeys=',
        selectorCoverImg = 'img.cover-image',
        batches = [];

    function init() {
      var listCoverImgs = $parent.find(selectorCoverImg),
          totalCovers = listCoverImgs.length;

      // batch by batch-cutoff value
      while (totalCovers > 0) {
        batches.push(listCoverImgs.splice(0, booksPerAjaxCall));
        totalCovers = listCoverImgs.length;
      }

      addBookCoversByBatch();
    }

    function addBookCoversByBatch() {
      $.each(batches, function(index, batch) {
        var bibkeys = getBibKeysForBatch(batch),
            batchBooksApiUrl = booksApiUrl + bibkeys;

        $.ajax({
          type: 'GET',
          url: batchBooksApiUrl,
          async: false,
          contentType: "application/json",
          dataType: 'jsonp',

          success: function(json) {
            renderCoverAndAccessPanel(json);
          },

          error: function(e) {
            console.log(e);
          }
        });

      });
    }

    function renderCoverAndAccessPanel(json) {
      $.each(json, function(bibkey, data) {
        if (typeof data.thumbnail_url !== 'undefined') {
          renderCoverImage(bibkey, data);
        }

        //if (typeof data.info_url !== 'undefined') {
        //  renderAccessPanel(bibkey, data);
        //}
      });
    }

    function renderCoverImage(bibkey, data) {
      var thumbUrl = data.thumbnail_url,
          selectorCoverImg = 'img.'+ bibkey;

      thumbUrl = thumbUrl.replace(/zoom=5/, 'zoom=1');
      thumbUrl = thumbUrl.replace(/&?edge=curl/, '');

      var imageEl = $parent.find(selectorCoverImg);

      imageEl
        .attr('src', thumbUrl)
        .removeClass('hide')
        .addClass('show');

      //remove hide
      imageEl.parent().removeClass('hide');

      var previewEl = imageEl.parent().find('span.preview-info a');

      previewEl.attr('href', data.preview_url)
        .removeClass('hide')
        .addClass('show');
    }


    function getBibKeysForBatch(batch) {
      var bibkeys = '';

      $.each(batch, function(index) {
        var $CoverImg = $(this),
            isbn = $CoverImg.data('isbn') || '',
            oclc = $CoverImg.data('oclc') || '',
            lccn = $CoverImg.data('lccn') || '';

        bibkeys += [isbn, oclc, lccn].join(',') + ',';
      });

      bibkeys = bibkeys.replace(/,,/, '');
      bibkeys = bibkeys.replace(/,$/, '');

      return bibkeys;
    }

    return this.each(function() {
      $parent = $(this);
      init();
    });
  }

})(jQuery);

Blacklight.onLoad(function() {
  $('#documents').plugGoogleBookContent();
  $('div#content .document').plugGoogleBookContent();
  //$('.accordion-section').plugGoogleBookContent();
});

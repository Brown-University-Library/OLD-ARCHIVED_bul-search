// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require 'blacklight_advanced_search'

//= require jquery_ujs
//= require turbolinks
//
// Required by Blacklight
//= require blacklight/blacklight
//= require_tree ./global

//= require underscore-min


//= require handlebars.runtime
//= require_tree ./templates
//= require handlebars.helpers

//= require jquery.plug-google-content

//= require bootstrap/tooltip
//= require bootstrap/popover
//= require infobox

//= require analytics



// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'


// Shelf-Browse
//= require 'jquery.stackview.min.js'


// ------------------------------
// Functions used to display the option to Scan an
// item or request it.

// Only items from the Annex that are books and periodical
// titles can be requested.
// I think we might need to add a check on "status" since
// only Available items can be requested.
// See https://github.com/Brown-University-Library/easyscan/blob/391cbef95f4731894a0b0b30cf15f062263fd77e/easyscan_app/lib/josiah_easyscan.js#L214-L224
function canScanItem(location, format) {
  var location = (location || "").toLowerCase();
  var format = (format || "").toLowerCase();
  if (location != "annex") {
    return false;
  }
  if ((format != "book") && (format != "periodical title")) {
    return false;
  }
  return true;
}


function easyScanFullLink(scanLink, bib, title) {
  return scanLink + '&title=' + title + '&bibnum=' + bib;
}


function itemRequestFullLink(barCode, bib) {
  return "https://library.brown.edu/easyrequest/login/?bibnum=" + bib + "&barcode=" + barCode;
}


function jcbRequestFullLink( item ) {
  console.log( item );
  var jcb_ref_num = "b6344512";
  var jcb_title = "The%20papers%20of%20Thomas%20Jefferson.%20Retirement%20series%20%2F%20J.%20Jefferson%20Looney%2C%20editor%20...%20%5Bet%20al.%5D";
  var jcb_author = "Jefferson%2C%20Thomas%2C%201743-1826";
  var jcb_publisher = "Princeton%20%3A%20Princeton%20University%20Press%2C%202004-%3C2012%3E";
  var jcb_callnumber = "E302%20.J442%202004";
  return "https://jcbl.aeon.atlas-sys.com/aeon.dll?Action=10&Form=30&ReferenceNumber=" + jcb_ref_num + "&ItemTitle=" + jcb_title + "&ItemAuthor=" + jcb_author + "&ItemPublisher=" + jcb_publisher + "&CallNumber=" + jcb_callnumber + "&ItemInfo2=";
}

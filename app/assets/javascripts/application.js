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


// ==========================
// General utility functions
// ==========================
function josiahGetUrlParameter(param) {
  var url = window.location.search.substring(1);
  var params = url.split('&');
  var i, tokens;
  for (var i = 0; i < params.length; i++) {
    tokens = params[i].split('=');
    if (tokens[0] == param) {
      return tokens[1];
    }
  }
  return null;
}


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


/*
============================================================
JCB Aeon link code
============================================================
Reference Josiah pages: TODO- update these to search.library.brown.edu urls
- `JCB`: <http://josiah.brown.edu/record=b3902979>
- `JCB REF`: <http://josiah.brown.edu/record=b6344512>
- `JCB VISUAL MATERIALS`: <http://josiah.brown.edu/record=b5660654>
- `JCB - multiple copies`: <http://josiah.brown.edu/record=b2223864>
- Very-long-title handling: <http://josiah.brown.edu/record=b5713050>  */

function jcbRequestFullLink( bib, title, author, publisher, callnumber ) {
  // console.log( item );
  var jcb_ref_num = bib;
  var jcb_title = extractTitle( title );
  var jcb_author = extractAuthor( author );
  var jcb_publisher = publisher;  // pre-sliced
  var jcb_callnumber = callnumber;
  return "https://jcbl.aeon.atlas-sys.com/aeon.dll?Action=10&Form=30&ReferenceNumber=" + jcb_ref_num + "&ItemTitle=" + jcb_title + "&ItemAuthor=" + jcb_author + "&ItemPublisher=" + jcb_publisher + "&CallNumber=" + jcb_callnumber + "&ItemInfo2=";
}

/*
END JCB link code
=================  */


/*
============================================================
Hay Aeon link code
============================================================
Note: initially very similar to JCB link code, but I (bjd) expect this to end up being different
Reference Josiah pages: TODO- update these to search.library.brown.edu urls
- `HAY BROADSIDES` - regular: <http://josiah.brown.edu/record=b3326323>
- `HAY BROADSIDES` - multiple 'HAY BROADSIDES' copies: <http://josiah.brown.edu/record=b3000585>
- `HAY STAR & HAY LINCOLN` - multiple copies, mixture of two: <http://josiah.brown.edu/record=b1870356>
- `HAY STAR` - very-long-title handling: <http://josiah.brown.edu/record=b1001443>  */

function hayAeonFullLink( bib, title, author, publisher, callnumber ) {
  /* called by catalog_record_availability.js */
  // console.log( item );
  var hayA_root_url = "https://brown.aeon.atlas-sys.com/logon/?Action=10&Form=30";
  var hayA_ref_num = bib;
  var hayA_title = extractTitle( title );
  var hayA_author = extractAuthor( author );
  var hayA_publisher = publisher;  // pre-sliced
  var hayA_callnumber = callnumber;
  var full_url = hayA_root_url + "?Action=10&Form=30" + "&ReferenceNumber=" + hayA_ref_num + "&ItemTitle=" + hayA_title + "&ItemAuthor=" + hayA_author + "&ItemPublisher=" + hayA_publisher + "&CallNumber=" + hayA_callnumber + "&ItemInfo2=";
  return full_url;
}

function isValidHayAeonLocation( item['location'] ) {
  /* called by catalog_record_availability.js */
  var hay_found = false;
  var non_aeon_locations = [
      "HAY ANNEX TEMP",
      "HAY ARCHIVES MANUSCRIPTS",
      "HAY COURSE RESERVES",
      "HAY MANUSCRIPTS"
      ];
  for( var i=0; i < bib_items_entry_rows.length; i++ ) {
      var row = bib_items_entry_rows[i];
      var josiah_location = row.children[0].textContent.trim();
      console.log( "- current josiah_location, `" + josiah_location + "`" );
      if ( josiah_location.slice(0, 3) == "HAY" ){
          console.log( "- seeing HAY slice" );
          var index_of_val = non_aeon_locations.indexOf( josiah_location );
          console.log( "- indexOf(josiah_location) was `" + index_of_val + "`" );
          if ( index_of_val == -1 ) {
              console.log( "- hay_found is `true`" );
              hay_found = true;
              break;
          }
      }
  }
  return hay_found;

}

/*
END Hay Aeon link code
======================  */


/*
============================================================
common Aeon link code
============================================================  */

function extractTitle( title ) {
  var t = title;
  if ( title.length > 100 ) {
    t = title.slice( 0, 97 ) + "..."; }
  return t;
}

function extractAuthor( author ) {
  var a = author;
  if ( author.length > 100 ) {
    a = author.slice( 0, 97 ) + "..."; }
  return a;
}

/*
END common link code
====================  */

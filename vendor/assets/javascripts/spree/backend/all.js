// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// @note must be loaded before all other scripts
//    require jquery
//    require jquery.turbolinks
//
//    require all else...
//
//    require turbolinks
//
// The reason for jQuery.turbolinks being before all scripts is so to let it
// hijack the $(function() { ... }) call that your other scripts will use.
//
// Turbolinks then needs to be at the end because it has to be the last to
// install the click handler, so not to interfere with other scripts.
//
// Source https://coderwall.com/p/ypzfdw/faster-page-loads-with-turbolinks
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require spree/backend

//= require_tree .

//= require spree/backend/spree_multi_domain
//= require spree/backend/spree_multi_currency
//= require spree/backend/spree_price_books
//= require spree/backend/spree_i18n
//= require spree/backend/spree_volume_pricing
//= require spree/braintree

//= require turbolinks


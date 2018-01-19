(function ($, window) {
  'use strict';

  // Do not allow pinned site on iOS to open links in a browser.
  if (/iphone|ipod|ipad/i.test(window.navigator.userAgent)) {
    $('a[href]').on('click', function (event) {
      event.preventDefault();

      location.href = this.href;
    });
  }
})(window.jQuery, window);

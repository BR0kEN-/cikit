(function (window, document) {
  'use strict';

  // Do not allow pinned site on iOS to open links in a browser.
  if (/iphone|ipod|ipad/i.test(window.navigator.userAgent)) {
    document.querySelectorAll('a[href]').forEach(function (link) {
      link.addEventListener('click', function (event) {
        event.preventDefault();

        location.href = this.href;
      });
    });
  }
})(window, window.document);

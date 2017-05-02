//= require_self
//= require_tree ./app

(function () {
  this.App = this.App || {};
  var App = this.App;

  var isTurbolinks = 'Turbolinks' in window && window.Turbolinks.supported;
  var isTurbolinks5 = isTurbolinks && 'clearCache' in window.Turbolinks;

  var onPageLoadFiredOnce = false;
  var pageLoadCallbacks = [];
  var triggerOnPageLoad = function () {
    pageLoadCallbacks.forEach(function (callback) {
      callback();
    });
    onPageLoadFiredOnce = true;
  };

  // Fires the callback on DOMContentLoaded or a Turbolinks page load.
  // If called from an async script on the first page load, and the DOMContentLoad event
  // has already fired, will execute the callback immediately.
  App.onPageLoad = function (callback) {
    pageLoadCallbacks.push(callback);
    // With async script loading, a callback may be added after the DOMContentLoaded event has already triggered.
    // This means we will receive neither a DOMContentLoaded event, nor a turbolinks:load event on Turbolinks 5.
    if (!onPageLoadFiredOnce && App.DOMContentLoadedFired) {
      callback();
    }
  };

  if (isTurbolinks5) {
    // In Turbolinks 5.0.1, turbolinks:load may have already fired (before DOMContentLoaded).
    // If so, add our own DOMContentLoaded listener:
    // See: https://github.com/turbolinks/turbolinks/commit/69d353ea73d10ee6b25c2866fc5706879ba403e3
    if (window.Turbolinks.controller.lastRenderedLocation) {
      document.addEventListener('DOMContentLoaded', function() {
        triggerOnPageLoad();
      });
    }
    document.addEventListener('turbolinks:load', function () {
      triggerOnPageLoad();
    });
  } else {
    // Turbolinks Classic (with or without jQuery.Turbolinks), or no Turbolinks:
    if (!App.DOMContentLoadedFired) {
      document.addEventListener('DOMContentLoaded', function () {
        triggerOnPageLoad();
      });
    }
    if (isTurbolinks) {
      document.addEventListener('page:load', function () {
        triggerOnPageLoad();
      })
    }
  }

  App.isAppPage = function() {
    return !!document.getElementById('app-page-container');
  }
}).call(this);

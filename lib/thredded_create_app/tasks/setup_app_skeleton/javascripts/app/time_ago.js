//= require timeago
(function() {
  window.App.onPageLoad(function() {
    if (!window.App.isAppPage()) {
      return;
    }
    var COMPONENT_SELECTOR = '[data-time-ago]';
    window.timeago().render(
        document.querySelectorAll(COMPONENT_SELECTOR),
        document.querySelector('#app-page-container')
            .getAttribute('data-locale'));
  });
  document.addEventListener('turbolinks:before-cache', function() {
    timeago.cancel();
  });
})();

//= require jquery.timeago
(function () {
  if (!this.App.isAppPage()) {
    return;
  }
  var COMPONENT_SELECTOR = '[data-time-ago]';
  this.App.onPageLoad(function () {
    const allowFutureWas = jQuery.timeago.settings.allowFuture;
    jQuery.timeago.settings.allowFuture = true;
    jQuery(COMPONENT_SELECTOR).timeago();
    jQuery.timeago.settings.allowFuture = allowFutureWas;
  });
}).call(this);

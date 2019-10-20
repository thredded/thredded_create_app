import {isAppPage, onPageLoad} from "./app";

onPageLoad(() => {
  if (!isAppPage()) return;
  const COMPONENT_SELECTOR = '[data-time-ago]';
  window.timeago().render(
      document.querySelectorAll(COMPONENT_SELECTOR),
      document.querySelector('#app-page-container')
          .getAttribute('data-locale').replace('-', '_'));
});
document.addEventListener('turbolinks:before-cache', () => {
  window.timeago.cancel();
});

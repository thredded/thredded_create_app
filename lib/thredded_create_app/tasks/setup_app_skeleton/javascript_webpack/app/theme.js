import {onPageLoad} from './app';

onPageLoad(() => {
  Array.prototype.forEach.call(document.querySelectorAll('.app-nav-theme li button'), (button) => {
    button.addEventListener('click', (evt) => {
      const expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + 12);
      document.cookie = 'app-theme=' +
          evt.currentTarget.parentNode.getAttribute('data-theme') +
          ';expires=' + expiresAt + ';path=/';
      document.location.reload();
    });
  });
});

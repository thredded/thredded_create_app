window.App.onPageLoad(function () {
  Array.prototype.forEach.call(document.querySelectorAll('.app-nav-theme li button'), function(button) {
    button.addEventListener('click', function(evt) {
      var expiresAt = new Date();
      expiresAt.setMonth(expiresAt.getMonth() + 12);
      document.cookie = 'app-theme=' +
          evt.currentTarget.parentNode.getAttribute('data-theme') +
          ';expires=' + expiresAt + ';path=/';
      document.location.reload();
    });
  });
});



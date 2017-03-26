window.App.onPageLoad(function () {
  jQuery('.app-nav-theme li button').click(function(evt) {
    var expiresAt = new Date();
    expiresAt.setMonth(expiresAt.getMonth() + 12);
    document.cookie = 'app-theme=' + $(this.parentNode).data('theme') +
        ';expires=' + expiresAt + ';path=/';
    document.location.reload();
  });
});



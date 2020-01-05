# v0.2.1

* Fix bundler error. #18
* Fix `inline_svg` deprecation warning.

# v0.2.0

* Now uses Webpack for JavaScript by default.
  To use Sprockets instead pass `--no-webpack-js`.

# v0.1.28

* Rails 6 support, using Sprockets for now.
* Fixed generator to work with the latest version of Devise (v4.7.1)

  Devise commit: https://github.com/plataformatec/devise/commit/76b87dc0e83736cf16e3ffbc465fcd8ee3c06d46#diff-fc9dcab47d10e11cb5c43f4a83df6cf4L4

# v0.1.27

* Fixed generator to work with the latest version of Devise.
  [#14](https://github.com/thredded/thredded_create_app/issues/14)

# v0.1.26

* Emoji via `gemoji` v2 are no longer installed by default.

# v0.1.25

* Adds `invisible_captcha` to the sign up form.

# v0.1.24

* Adds a "Send private message" link to user profile.
* Removes password confirmation from sign up.
* "Remember me" checked by default on sign in.
* On `LoginRequired` error, now uses the sign in controller to render the login
  form.

# v0.1.23

* Fixes installation on Rails 5.2.0.rc1.
  [#12](https://github.com/thredded/thredded_create_app/issues/12)

# v0.1.22

* Fixed timeago.js with locales that contain a hyphen (e.g. `zh-CN`).

# v0.1.21

* No longer adds jQuery. Compatible with thredded v0.13.0+.

# v0.1.20

* Fix Devise setup.

# v0.1.19

* Configures Thredded to use `rails-ujs` (default in Rails v5.1.1) instead of
  `jquery_ujs`.

# v0.1.18

* Support Rails 5.1.

# v0.1.17

* Allow passing in `--rails-version`.

# v0.1.16

* Support Turbolinks v5.0.1.

# v0.1.15

* Add the `config` gem to have a single source of truth for configuration such
  as the app's hostname (domain) and the default email sender.
* Configure Devise mailers.

# v0.1.14

* A minor change to Roadie config as per
  https://github.com/Mange/roadie-rails/issues/11#issuecomment-289299465.

# v0.1.13

* Add day/night theme switcher.
* Add a Turbolinks monkey-patch for https://github.com/turbolinks/turbolinks/issues/179.
* Improve styles structure.

# v0.1.12

Add Roadie and RailsEmailPreview.

# v0.1.11

Fix sign out when the app's root path is at Thredded
(so `root_path` is not defined).

# v0.1.10

Fix user page recent posts display.

# v0.1.9

Add production Memcached configuration for Heroku and
[Thredded Ansible playbooks](https://github.com/thredded/thredded-ansible).

# V0.1.8

Add production Puma configuration for
[Thredded Ansible playbooks](https://github.com/thredded/thredded-ansible).

# v0.1.7

Simplify setup for non-rubyists:

1. List the required packages for compiling the app's gem dependencies.
2. Instructions and compatibility for running using the system ruby.
3. Instructions for Heroku deployment and app compatibility with Ruby 2.2
   (as that's what Heroku runs by default).

# v0.1.6

* Fix `<title>` escaping.
* Remove browser margin on `body.app`.

# v0.1.5

* Support Ruby 2.4.
* Support postgresql usernames containing a `-`.
  [#8](https://github.com/thredded/thredded_create_app/issues/8)

# v0.1.4

* Edit my account page.
* jQuery.timeago JS in main_app.

# v0.1.2

Enable using MySQL v5.6.4+ or SQLite3 via the `--database` argument.

# v0.1.0

Initial release.

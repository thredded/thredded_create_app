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

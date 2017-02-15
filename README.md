# ThreddedCreateApp [![Build Status](https://travis-ci.org/thredded/thredded_create_app.svg?branch=master)](https://travis-ci.org/thredded/thredded_create_app) [![Test Coverage](https://codeclimate.com/github/thredded/thredded_create_app/badges/coverage.svg)](https://codeclimate.com/github/thredded/thredded_create_app/coverage)

Generates a Rails app with the [Thredded](https://github.com/thredded/thredded) forums engine installed.

See below for more information on the generated app.

Example screenshots of the generated app:

<table>
  <tr>
    <td><img alt="Home" src="https://cloud.githubusercontent.com/assets/216339/19858280/23072dd8-9f3e-11e6-8d71-e977a4a67f0f.png"></td>
    <td><img alt="Sign Up" src="https://cloud.githubusercontent.com/assets/216339/19858282/231bb06e-9f3e-11e6-8e51-a293523b7034.png"></td>
  </tr>
  <tr>
    <td><img alt="Messageboard" src="https://cloud.githubusercontent.com/assets/216339/19858469/c592413c-9f3e-11e6-827d-b530f3ee2850.png"></td>
    <td><img alt="Topic" src="https://cloud.githubusercontent.com/assets/216339/19858284/232107e4-9f3e-11e6-8c5f-8a8f927f2922.png"></td>
  </tr>
</table>

## Pre-requisites

1. Git.
2. A supported database: PostgreSQL (recommended), MySQL v5.7+, or SQLite.
3. Ruby 2.3+.

You may also need some packages to compile Thredded dependencies.
On Ubuntu, you can install all the required packages by running:

```bash
sudo apt-get install autoconf automake bison build-essential gawk git \
  libffi-dev libgdbm-dev libgmp-dev libncurses5-dev libpq-dev libreadline6-dev \
  libsqlite3-dev libtool libyaml-dev nodejs pkg-config ruby sqlite3
```

## Usage

Install the gem and create your app:

```bash
gem install thredded_create_app
```

#### Installing the gem using system Ruby

When using the *system* Ruby on Mac or Linux (as opposed to RVM or rbenv),
the command above will fail because only root can install gems system-wide.

Instead, install `thredded_create_app` with the `--user` flag:

```bash
gem install --user thredded_create_app
```

The above will install the gem to the `~/.gem/` directory.

Then, [add the user gems `bin` directory to `PATH`](http://guides.rubygems.org/faqs/#user-install).

### Create your app

```
thredded_create_app myapp
```

By default, PostgreSQL will be used as the database.
Alternatively, you can pass `--database sqlite3` for SQLite,
or `--datase mysql2` for MySQL.

Run `thredded_create_app --help` for more information about the available
options.

### App generation

The app generator will do the steps below for you.

First, the rubygems package is updated and the latest versions of
[Rails] and [Bundler] are installed.

Then, a Rails app is generated for use with the selected database.

Then, a [git] repository is initialized in the app directory. From here onwards,
the app generator will commit the changes at each step.

[RSpec] is used as the testing framework, and some basic acceptance tests
using [capybara] are added.

[Devise] is used as the authentication framework. Its default views are
customized to add a user name field (`display_name`) to the registration form.
The [simple_form] gem is used for the customized Devise views by default.

A basic responsive app layout with top bar navigation is added.
A user profile page that displays some basic information about the user and
their recent forum posts is also added.

The app comes with basic styles (~10KiB gzipped, including Thredded styles)
that are written using [Sass].

The app's JavaScript code is loaded asynchronously in production mode via the
[`async`] attribute on the script tag. In development, the individual script
files are not concatenated. With `async` they would load out-of-order, so
[`defer`] is used instead.

**NB:** While loading scripts via `async` provides the best possible speed,
a lot of JavaScript libraries do not support it.
**If** you plan on adding JavaScript code, you might want to
**remove the `async` attribute** from the `javascript_include_tag` in
`app/views/layouts/application.html.erb`.

A [Dockerfile] and [docker-compose.yml] is generated for development.
This is so that other engineers can spin up a development environment with
a single command.

A production configuration file for the [puma] Ruby web server is created.
A `Procfile` process description file is also created. This file can be used by
the [Heroku] hosting platform or the [foreman] app runner.

Lastly, the `$APP` database user is created and given rights to the app's
development and test databases. Then, the database is created, the migrations
are run, and the database is seeded with an admin user and a messageboard.

Finally, the tests are run, and the development web server is started at
<http://localhost:3000>.

[`async`]: https://developer.mozilla.org/en/docs/Web/HTML/Element/script
[`defer`]: https://developer.mozilla.org/en/docs/Web/HTML/Element/script
[Bundler]: http://bundler.io/
[capybara]: https://github.com/jnicklas/capybara
[Devise]: https://github.com/plataformatec/devise
[docker-compose.yml]: https://docs.docker.com/compose/
[Dockerfile]: https://docs.docker.com/engine/reference/builder/
[foreman]: https://ddollar.github.io/foreman/
[git]: https://git-scm.com/
[Heroku]: https://www.heroku.com/
[puma]: https://github.com/puma/puma
[Rails]: http://rubyonrails.org/
[RSpec]: http://rspec.info/
[Sass]: http://sass-lang.com/
[simple_form]: https://github.com/plataformatec/simple_form

### Next steps

To learn about customizing the forums, see the [Thredded Readme].

To learn about customizing the authentication system, e.g. to require email
confirmation or to add an OAuth login, see the [Devise Readme].

To change the homepage, edit the view file at `app/views/home/show.html.erb`.

To change the app's styles, see the files in `app/assets/stylesheets`.
The app is generated with a randomly selected primary theme color that you may
want to change. You can find it in `app/assets/stylesheets/_variables.scss`.

You can contact the Thredded team via the [Thredded chat room].
Once you've deployed your app, please let us know that you are using Thredded
by tweeting [@thredded]!

[@thredded]: https://twitter.com/thredded
[Devise Readme]: https://github.com/plataformatec/devise/blob/master/README.md
[Thredded chat room]: https://gitter.im/thredded/thredded
[Thredded Readme]: https://github.com/thredded/thredded/blob/master/README.md

## Deploying to Heroku

To deploy your app to Heroku, run:

```bash
gem install heroku # --user if using system ruby
# Create a heroku app and set the necessary environment variables
heroku create
heroku config:set RACK_ENV=production RAILS_ENV=production \
  SECRET_KEY_BASE="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
# Deploy to heroku
git push heroku master
# Set up the database and some seed data (an admin user and a messageboard)
heroku run rake db:migrate db:seed
# Open the website in your default browser
heroku open
```

You can log in as the admin user with email `admin@<app name>.com`, password
`123456`.

The app is now deployed, but you'll also need to set up emailing, either by
using one of the Heroku add-ons (there are some free ones), or by
[configuring it yourself](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration).

## Development

The instructions below are for developing and contributing to
the Thredded app generator itself, not for using it.

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you
to experiment.

To generate an app with `thredded_create_app` at `tmp/myapp`, run:

```sh
bundle exec bin/create-tmp-myapp
```

This command will clean up the previously generated app before creating
a new one.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/thredded/thredded_create_app.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).


# ThreddedCreateApp [![Build Status](https://travis-ci.org/thredded/thredded_create_app.svg?branch=master)](https://travis-ci.org/thredded/thredded_create_app)

**THIS IS A WORK-IN-PROGRESS REPO AND IS NOT YET USABLE**.

Generates a Rails app with the [Thredded](https://github.com/thredded/thredded) forums engine installed.

This generator will create a new Rails app with the following configuration:

* Database: PostgreSQL.
* Auth: Devise.

## Pre-requisites

1. PostgreSQL.
2. Ruby 2.1+.

## Usage

First, install the gem:

```bash
gem install thredded_create_app
```

Then, run the command below depending on how you installed your ruby:

* If using system ruby:
 
   ```bash
   thredded_create_app myapp
   ```

* If using [RVM](https://rvm.io/):

   ```bash
   RUBY_VERSION=2.3.1 APP=myapp
   rvm use --create "${RUBY_VERSION}@${APP}"
   thredded_create_app $APP
   ```
   
   Then, generate .ruby-version and .ruby-gemset:
 
   ```bash
   cd myapp
   rvm use --ruby-version "${RUBY_VERSION}@${APP}"
   printf '.ruby-version\n.ruby-gemset\n' >> .git/info/exclude
   ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thredded/thredded_create_app.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


# ThreddedCreateApp [![Build Status](https://travis-ci.org/thredded/thredded_create_app.svg?branch=master)](https://travis-ci.org/thredded/thredded_create_app) [![Test Coverage](https://codeclimate.com/github/thredded/thredded_create_app/badges/coverage.svg)](https://codeclimate.com/github/thredded/thredded_create_app/coverage)

**THIS IS A WORK-IN-PROGRESS REPO AND IS NOT YET USABLE**.

Generates a Rails app with the [Thredded](https://github.com/thredded/thredded) forums engine installed.

This generator will create a new Rails app with the following configuration:

* Database: PostgreSQL.
* Auth: Devise.

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
2. PostgreSQL.
3. Ruby 2.3+.

## Usage

Install the gem and create your app:

```bash
gem install thredded_create_app
thredded_create_app myapp
```

### More detailed instructions

Run `thredded_create_app --help` for more information about the available
options.

#### RVM

If you're using [RVM](https://rvm.io/), you probably want to create a
gemset before creating your app:

 ```bash
 RUBY_VERSION=2.3.1 APP=myapp
 rvm use --create "${RUBY_VERSION}@${APP}"
 gem install thredded_create_app
 thredded_create_app "$APP"
 ```
   
Then, generate the `.ruby-version` and `.ruby-gemset` files so that the gemset
is used automatically whenever you `cd` into the project directory:
 
 ```bash
 cd "$APP"
 rvm use --ruby-version "${RUBY_VERSION}@${APP}"
 printf '.ruby-version\n.ruby-gemset\n' >> .git/info/exclude
 ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To generate an app with `thredded_create_app` at `tmp/myapp`, run:

```sh
bundle exec bin/create-tmp-myapp
```

This command will clean up the previously generated app before creating a new one.

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


[![Build Status](https://travis-ci.org/adamstrickland/popcorn.svg?branch=master)](https://travis-ci.org/adamstrickland/popcorn) [![Code Climate](https://codeclimate.com/github/adamstrickland/popcorn/badges/gpa.svg)](https://codeclimate.com/github/adamstrickland/popcorn) [![Test Coverage](https://codeclimate.com/github/adamstrickland/popcorn/badges/coverage.svg)](https://codeclimate.com/github/adamstrickland/popcorn/coverage) [![Issue Count](https://codeclimate.com/github/adamstrickland/popcorn/badges/issue_count.svg)](https://codeclimate.com/github/adamstrickland/popcorn/issues)

# Popcorn

[OpenAPI](https://www.openapis.org/) is good.  It's straightforward-yet-robust, easily understood, and best-of-all, it's [open](https://www.openapis.org/participate/how-to-contribute).  However, I found that there are several shortcomings not addressed by the spec, that hinder my usage of it.  __Popcorn__ is an attempt to alleviate some of those shortcomings.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'popcorn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install popcorn

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wellmatchdev/popcorn.

### ToDo

The following is a quick list of things I want to do with this:

- Add a validation command
- Run a mock service based on the APIs
- Containerize it so usage is as easy as

  ```yaml
  popcornui:
    image: adamstrickland/popcorn:ui
    ports:
      - 80:3000
    volumes:
      - .:/src

  popcornmockapi:
    image: adamstrickland/popcorn:mockapi
    ports:
      - 80:3000
    volumes:
      - .:/src
  ```

- Support for examples and/or data-generators
- Add commenting?


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


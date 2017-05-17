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

Popcorn is a simple executable (thanks, [Thor](http://whatisthor.com)!).  The command

```bash
popcorn generate SRC DEST
```

will ingest the directory structure at `SRC` and output a valid OpenAPI schema to `DEST`.  The expected directory directory structure underneath `SRC` is as follows

```
src/
  apis/
    foo.yml
  paths/
    foos.yml
    foo.yml
  definitions/
    foo.yml
```

Using the above as an example, `popcorn` will parse all the files in `src/apis/` and import any referenced files therein, understood to contain OpenAPI [path](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#pathsObject) definitions within the `src/paths/` directory and [definition](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#definitionsObject) structures in the `src/definitions/` folder.  `src/apis/foo.yml` may look like

```
swagger: '2.0'
info:
  version: "1.0.0"
  title: Foo API
paths:
  include:
    - foos.yml
    - foo.yml
definitions:
  include:
    - foo.yml
```

which would incorporate `src/paths/foos.yml` and `src/paths/foo.yml` into the resulting `path` construct and the content of `src/definitions/foo.yml` into the `definitions` construct.  For more examples, refer to the [specs](./tree/master/spec) and [fixtures](./tree/master/spec/fixtures). The resulting OpenAPI definition would end up in `DEST/apis/foo.yml`.  More on this below.

By default, `popcorn` will also generate an `index.html` in the `DEST` folder.  As the reader may or may not know from the OpenAPI spec, OpenAPI expects a single, canonical (read: **LARGE**) API definition file.  This is intended as something of a workaround for same.  The generated `index.html` is straightforward, basically containing links to the APIs residing in the `DEST/apis/` subdirectory; in the above example, there would be but one link, to `DEST/apis/foo.yml`.  This is a link to the canonical [swagger-ui](http://swagger.io/swagger-ui), with the API passed to it, allowing the user to interact with said API.

There is also an option to generate only the canonical single-file, using `--no-multi`.  In this case, all of the defined APIs are merged into the one file, for easy use/deployment.  Personally I think that's too much, but to each their own. `¯\_(ツ)_/¯`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Be aware that [Travis CI](https://travis-ci.org/adamstrickland/popcorn) will run both [rubocop](https://github.com/bbatsov/rubocop) and [code climate](https://codeclimate.com/github/adamstrickland/popcorn), possibly causing the build to fail there.  For that reason, it is recommended that, before pushing, the developer also run these commands locally.

Personally, I use [guard](https://github.com/guard/guard) like it's going out of style.  The [Guardfile](./tree/master/Guardfile) has an appropriate setup to do a full check (hint: use it).

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
- Custom directory structure(s)
- JSON output?
- Custom index.html template

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


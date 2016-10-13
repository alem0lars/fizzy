# Changes

## Next version

### User changes

* Add logic expressions support for `only` in the meta.
* Add fizzy command: `version` to show fizzy version
  and environment information, like ruby version.

### Dev changes

* Add some documents for contributors:
  * `CODE_OF_CONDUCT.md`
  * `CONTRIBUTING.md`
  * `STYLE_GUIDE.md`
* Refactor `Rakefile` into `tasks` directory.
* Add some `IO` shortcuts for *well-known messages*:
  * `✔`
  * `✘`
* Add `Hash` extensions to convert keys (and relative unit-tests):
  * `#deep_symbolize_keys`
  * `#deep_stringify_keys`
  * `#deep_transform_keys`
* Add `Hash` extension to get some key/value pairs: `sample(n)`
* Migrate meta keys *from strings to symbols*
* Migrate variables keys *from strings to symbols* (see `parse_vars(..)`)
  and have indifferent access (see `_get_var(..)`).
* API documentation (using `yard`). The following tasks were added:
  * `rake doc:generate`: Generate the API documentation.
  * `rake doc:server`: Serve the API documentation in a local webserver
    (for testing purposes).
* *Docker support*, with a custom Docker image (defined in the `Dockerfile`)
  that automatically builds `fizzy` upon building the image.
  Also, a `rake` namespace called `docker` were added to group Docker-related
  tasks:
  * `rake docker:test`
  * `rake docker:repl`
  * `rake docker:console`
  * `rake docker:prepare`
* Add `must`, used for implementing pre-conditions / post-conditions
* Add `Fizzy::Caller` class, used to retrieve information about the
  caller.
* Preprocess source files (using ERB) in build stage.
* Refactor project structure
* Collapse `gh-pages*` branches into master
* Migrate from minitest to rspec
* Integrate YARD API docs with fizzy website
* Integrate test results with fizzy website
* Integrate coverage results with fizzy website
* Handle more than one feature `has_feature?` method. `true` when none of the
  collection members are `false`. [@jak3][@jak3]


## Current and previous versions

See the release notes.

<!-- Link declarations -->

[@jak3]: https://github.com/jak3

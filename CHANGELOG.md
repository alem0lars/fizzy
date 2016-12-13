# Changes

## Next version

### User changes

* Add logic expressions support for `only` in the meta.
  [@alem0lars][@alem0lars]
* Add fizzy command: `version` to show fizzy version
  and environment information, like ruby version.
  [@alem0lars][@alem0lars]
* Allow strict regex matching with '^'
  [@alem0lars][@alem0lars]
* Enfore configuration elements to be inside `elems` directory.
  [@alem0lars][@alem0lars]
* Handle more than one feature `has_feature?` method.
  [@jak3][@jak3]
* Add `match` (optional) argument to `has_feature?` method.
  [@alem0lars][@alem0lars]
* Add `String` operations: `titleize`, `camelize`, `underscorize`, `dasherize`.
  [@alem0lars][@alem0lars]
* Add `Symbol` operations: `titleize`, `camelize`, `underscorize`, `dasherize`.
  [@alem0lars][@alem0lars]
* Allow to pass block in `variable` to perform transformation of variable for
  generating a new local.
  [@alem0lars][@alem0lars]

### Dev changes

* Add some documents for contributors:
  * `CODE_OF_CONDUCT.md`
  * `CONTRIBUTING.md`
  * `STYLE_GUIDE.md`
  [@alem0lars][@alem0lars]
* Refactor `Rakefile` into `tasks` directory.
  [@alem0lars][@alem0lars]
* Add some `IO` shortcuts for *well-known messages*:
  * `✔`
  * `✘`
  [@alem0lars][@alem0lars]
* Add `Hash` extensions to convert keys (and relative unit-tests):
  * `#deep_symbolize_keys`
  * `#deep_stringify_keys`
  * `#deep_transform_keys`
  [@alem0lars][@alem0lars]
* Add `Hash` extension to get some key/value pairs: `sample(n)`
  [@alem0lars][@alem0lars]
* Migrate meta keys *from strings to symbols*
  [@alem0lars][@alem0lars]
* Migrate variables keys *from strings to symbols* (see `parse_vars(..)`)
  and have indifferent access (see `_get_var(..)`).
  [@alem0lars][@alem0lars]
* API documentation (using `yard`). The following tasks were added:
  * `rake doc:generate`: Generate the API documentation.
  * `rake doc:server`: Serve the API documentation in a local webserver
    (for testing purposes).
  [@alem0lars][@alem0lars]
* *Docker support*, with a custom Docker image (defined in the `Dockerfile`)
  that automatically builds `fizzy` upon building the image.
  Also, a `rake` namespace called `docker` were added to group Docker-related
  tasks:
  * `rake docker:test`
  * `rake docker:repl`
  * `rake docker:console`
  * `rake docker:prepare`
  [@alem0lars][@alem0lars]
* Add `must`, used for implementing pre-conditions / post-conditions
  [@alem0lars][@alem0lars]
* Add `Fizzy::Caller` class, used to retrieve information about the
  caller.
  [@alem0lars][@alem0lars]
* Preprocess source files (using ERB) in build stage.
  [@alem0lars][@alem0lars]
* Refactor project structure
  [@alem0lars][@alem0lars]
* Collapse `gh-pages*` branches into master
  [@alem0lars][@alem0lars]
* Migrate from minitest to rspec
  [@alem0lars][@alem0lars]
* Integrate YARD API docs with fizzy website
  [@alem0lars][@alem0lars]
* Integrate test results with fizzy website
  [@alem0lars][@alem0lars]
* Integrate coverage results with fizzy website
  [@alem0lars][@alem0lars]


## Current and previous versions

See the release notes.


<!-- Link declarations -->

[@alem0lars]: https://github.com/alem0lars
[@jak3]:      https://github.com/jak3

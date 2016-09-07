# Changes

## Next version

- Refactor `Rakefile` into `tasks` directory.
- Add some `IO` shortcuts for *well-known messages*:
  - `✔`
  - `✘`
- Add `Hash` extensions to convert keys (and relative unit-tests):
  - `#deep_symbolize_keys`
  - `#deep_stringify_keys`
  - `#deep_transform_keys`
- Migrate meta keys *from strings to symbols*
- Migrate variables keys *from strings to symbols* (see `parse_vars(..)`)
  and have indifferent access (see `_get_var(..)`).
- Add some documents for contributors:
  - `CODE_OF_CONDUCT.md`
  - `CONTRIBUTING.md`
  - `STYLE_GUIDE.md`
- API documentation (using `yard`). The following tasks were added:
  - `rake doc:generate`: Generate the API documentation.
  - `rake doc:server`: Serve the API documentation in a local webserver
    (for testing purposes).
- Integration with [Hound CI][houndci].
- Add logic expressions support for `only` in the meta.
- *Docker support*, with a custom Docker image (defined in the `Dockerfile`)
  that automatically builds `fizzy` upon building the image.
  Also, a `rake` namespace called `docker` were added to group Docker-related
  tasks:
  - `rake docker:test`
  - `rake docker`
- Add `must`, used for implementing pre-conditions / post-conditions
- Add `Fizzy::Caller` class, used to retrieve information about the
  caller.

## Current and previous versions

See the release notes.

<!-- Link declarations -->

[houndci]: https://houndci.com

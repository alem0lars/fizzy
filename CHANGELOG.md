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
- Now variables have *symbols has keys* (see `parse_vars(..)`)
  and have indifferent access (see `_get_var(..)`).

## Current and previous versions

See the release notes.

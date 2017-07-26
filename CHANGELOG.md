# Changes

## Version 3.0.0

### User changes

* Remove dependency `thor`: now fizzy is without any dependency!
  You just need the ruby interpreter :D
  [@alem0lars][@alem0lars]
* Minor bug fixes
  [@alem0lars][@alem0lars]

#### Breaking changes

The following changes will break backward compatibility:

* Simplified command names (no more nesting, removed useless commands)
  [@alem0lars][@alem0lars]
  :
  * `cfg cd` → `cd`
  * `cfg cleanup` → `cleanup`
  * `cfg details` → `info`
  * `cfg edit` → `edit`
  * `cfg instantiate` has been removed
  * `cfg sync` → `sync`
  * `inst cd` has been removed
  * `inst install` has been removed
  * `quick-install` → `incarnate`
  * `usage` has been kept unchanged
  * `version` has been kept unchanged

* Rename utility functions
  [@alem0lars][@alem0lars]
  :
  * `is_osx?` → `osx?`
  * `is_windows?` → `windows?`
  * `is_linux?` → `linux?`

### Dev changes

* Refactor module `command` (and all pre-existing commands) into module `cli`
  using the new module `argparse` instead of `thor` gem
  [@alem0lars][@alem0lars]
* Implement module `argparse` to perform command-based argument parsing
  [@alem0lars][@alem0lars]
* Singularize module names
  [@alem0lars][@alem0lars]
* Update dependencies
  [@alem0lars][@alem0lars]
* Restore API documentation generation through rake task
  [@alem0lars][@alem0lars]
* Add more `Hash` utilities:
  `deep_merge`, `deep_merge!`, `magic_merge`, `magic_merge!`
  [@alem0lars][@alem0lars]
* Rename old `deep_merge` to `magic_merge` (that's the merge strategy used for
  vars and meta)
  [@alem0lars][@alem0lars]
* Update rubocop configuration to recent upstream updates
  [@alem0lars][@alem0lars]
* Add some vim utilities in `.exrc` to uniform linting/formatting
  [@alem0lars][@alem0lars]

## Previous versions

See the release notes.


<!-- Link declarations -->

[@alem0lars]: https://github.com/alem0lars
[@lmolr]:     https://github.com/lmolr
[@jak3]:      https://github.com/jak3

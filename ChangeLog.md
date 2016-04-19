# Changes

## Next version

- Build system and migration to a more modular source code organisation.
- Enhancements in git handling.
- DRY commands options (refactored in base class).
- Paths migration from simple strings to `pathname`.
- Change `cfg sync` option from `--url` to `--cfg-url` (abbreviated to `cu`).
- Drop support for Ruby `1.8`.
- Allow to use typed variables (`get_var` and derivative functions have `type`
  argument).
- `locals` abstraction (allow to specify `locals` variables to be used based on
  `vars` or other stuff. It also serves as a sort of requirements specification
  for the current file.
- Add grammars support, using `RACC` for writing parsers and `Fizzy::BaseLexer`
  for (regexp-based) lexers.
- Add grammar for logic expressions in `only` in `meta.yml`.
- Add rake `console` task (with fizzy preloaded).
- Allow to specify GitHub URLs using `username/reponame` shortcut.
- Stronger paths checks in `prepare_storage`.
- Add command `cfg info`.
- Allow to select variables (with `get_var` and derivatives) using regexp
  (e.g. `mercurial.mergetool.(name|cmd)`).
- Add function `xdg_config_home`.
- Add function `case_os`.
- Refactor types management in the `typesystem` module.
- Support `ERB` templates inside `vars` definition.
- Add `filters` feature.
- Add `lpass` filter.
* Add `download` meta command.

## Current and previous versions

See the release notes.

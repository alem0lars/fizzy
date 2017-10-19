" Use `rubocop` as linter.
let g:neomake_ruby_enabled_makers = ['rubocop']

" Use `rubocop` as formatter.
let g:formatters_ruby = ['rubocop']

" Add `./bin` folder (that should contain bundler binstubs) to `$PATH`.
let $PATH .= ':' . getcwd() . '/.binstub'

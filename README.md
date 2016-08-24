Fizzy
=====

The hassle free configuration manager

[![Bountysource][bountysource_image]][bountysource_link]

## Usage

The best way to learn how to use fizzy is to read the
**Official End-User Guide**:

- [**Read online**][read_end_user_guide]
- [**Download as PDF**][download_pdf_end_user_guide]
- [**Download as ePUB**][download_epub_end_user_guide]
- [**Download it as MOBI**][download_mobi_end_user_guide]

## Installation

Fizzy is distributed in two ways:

- **Standalone**: it includes just fizzy, as any other project.
  This is the *preferred* way to use fizzy in your machines.
- **Portable**: it includes everything:
  fizzy, its dependencies, a ruby interpreter.
  You may want to use this if you don't want to leave any traces,
  can't use or don't have a Ruby interpreter,
  don't have permissions to install fizzy dependencies.

### Bundle

First, [download the bundle][download_bundle]; then:

```shellsession
$ mkdir fizzy_portable
$ tar -xzf fizzy-*.tar.gz -C fizzy_portable
$ cd fizzy_portable
$ chmod +x ./fizzy
$ ./fizzy
```

### Standalone

#### MacOSX (standalone)

If you already haven't tapped the alem0lars HomeBrew repository, tap it:
```shellsession
$ brew tap alem0lars/homebrew-repo
```

Install via HomeBrew
```shellsession
$ brew install fizzy
```

#### One-liner (standalone)

The destination can be everywhere, I suggest `/usr/local/bin` in GNU/Linux
based systems because it's almost always in the `PATH` environment variable,
so you can run `fizzy` from everywhere.

```shellsession
$ curl -sL https://raw.githubusercontent.com/alem0lars/fizzy/master/build/fizzy | \
  sudo tee /usr/local/bin/fizzy > /dev/null && \
  sudo chmod +x /usr/local/bin/fizzy
```

#### Others (standalone)

You can provide integration with an existing package system.

The dependencies are:
* The [ruby][ruby_homepage] interpreter (`>= 2.0.0`)
* The [thor][thor_homepage] [gem][thor_gem]

Then you can drop [fizzy][fizzy_bin] everywhere (possibly in the system path)
and make it executable.

## Contributions

See [CONTRIBUTING.md][contributing]

**Contributions are welcome!**

## Pointers

* IRC channel: `#fizzy` at freenode

----

Made with ♥ by Alessandro Molari

- [@alem0lars][twitter]
- [molari.alessandro@gmail.com][send_email]

<!-- Link declarations -->

[twitter]:    https://twitter.com/alem0lars
[send_email]: mailto:molari.alessandro@gmail.com

[ruby_homepage]: https://www.ruby-lang.org
[thor_gem]:      https://rubygems.org/gems/thor
[thor_homepage]: http://whatisthor.com

[bountysource_image]: https://img.shields.io/bountysource/team/fizzy/activity.svg
[bountysource_link]:  https://www.bountysource.com/teams/fizzy

[read_end_user_guide]:          https://www.gitbook.com/read/book/alem0lars/fizzy
[download_pdf_end_user_guide]:  https://www.gitbook.com/download/pdf/book/alem0lars/fizzy
[download_epub_end_user_guide]: https://www.gitbook.com/download/epub/book/alem0lars/fizzy
[download_mobi_end_user_guide]: https://www.gitbook.com/download/mobi/book/alem0lars/fizzy

[download_bundle]: https://github.com/alem0lars/fizzy/releases

[fizzy_bin]:    ./build/fizzy
[contributing]: ./CONTRIBUTING.md

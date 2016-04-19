Fizzy
=====

The hassle free configuration manager

[![Bountysource](https://img.shields.io/bountysource/team/fizzy/activity.svg)]()

## Usage

A end-user guide is planned (see issue #21) but still not available.

## Installation

### MacOSX

If you already haven't tapped the alem0lars HomeBrew repository, tap it:
```shellsession
$ brew tap alem0lars/homebrew-repo
```

Install via HomeBrew
```shellsession
$ brew install fizzy
```

### One-liner

The destination can be everywhere, I suggest `/usr/local/bin` in GNU/Linux
based systems because it's almost always in the `PATH` environment variable,
so you can run `fizzy` from everywhere.

```shellsession
$ curl -sL https://raw.githubusercontent.com/alem0lars/fizzy/master/build/fizzy | \
  sudo tee /usr/local/bin/fizzy > /dev/null && \
  sudo chmod +x /usr/local/bin/fizzy
```

### Others

You can provide integration with an existing package system.

The dependencies are:
* The [ruby](https://www.ruby-lang.org) interpreter (`>= 2.0.0`)
* The [thor](http://whatisthor.com) [gem](https://rubygems.org/gems/thor)

Then you can drop [fizzy](./fizzy) everywhere (possibly in the system path) and
make it executable.

**Contributions are welcome!**

## Development notes

### Setup

Run:

```shellsession
$ bundle install
```

### Tasks

The common tasks are defined in the [`Rakefile`](./Rakefile)

To get a list of them:

```shellsession
$ bundle exec rake -T
```

### Test source code

```shellsession
$ bundle exec rake test
```

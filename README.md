Fizzy
=====

The hassle free configuration manager

[![Bountysource](https://img.shields.io/bountysource/team/fizzy/activity.svg)]()

## Installation

### MacOSX

If you already haven't tapped the alem0lars HomeBrew repository, tap it:
```ShellSession
$ brew tap alem0lars/homebrew-repo
```

Install via HomeBrew
```ShellSession
$ brew install fizzy
```

### One-liner

The destination can be everywhere, I suggest `/usr/local/bin` in GNU/Linux
based systems because it's almost always in the `PATH` environment variable,
so you can run `fizzy` from everywhere.

```ShellSession
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

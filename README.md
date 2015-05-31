Fizzy
=====

The hassle free configuration manager

![Status](http://img.shields.io/badge/status-Not%20released%20yet-yellow.svg) [![Stories in Ready](https://badge.waffle.io/alem0lars/fizzy.png?label=ready&title=Ready)](https://waffle.io/alem0lars/fizzy) [![Bountysource](https://img.shields.io/bountysource/team/fizzy/activity.svg)]()

## Installation

### MacOSX

If you already haven't tapped the alem0lars HomeBrew repository, tap it:
```ShellSession
$ brew tap alem0lars/homebrew-repo
```

Install via HomeBrew (use `--HEAD` since there isn't a version already released yet):
```ShellSession
$ brew install --HEAD fizzy
```

### One-liner

The destination can be everywhere, I suggest `/usr/local/bin` in GNU/Linux based systems because it's almost always in the `PATH` environment variable, so you can run `fizzy` from everywhere.

```ShellSession
$ curl https://raw.githubusercontent.com/alem0lars/fizzy/master/fizzy | sudo tee /usr/local/bin/fizzy > /dev/null
```

### Others

You can provide integration with an existing package system.

The dependencies are:
* The [ruby](https://www.ruby-lang.org) interpreter (`>= 2.0.0`)
* The [thor](http://whatisthor.com) [gem](https://rubygems.org/gems/thor)

then you can drop [fizzy](./fizzy) everywhere (possibly in the system path) and make it executable.

**Contributions are really welcome!**

## Available commands

### Sync

Sync with the remote configuration repository.

This command can be run as a unprivileged user or as root: it makes no difference.

#### Usage example

* *First sync*

  ```ShellSession
  $ fizzy cfg sync --url url_to_config
  ```

* *Other syncs* (there is no need to pass the URL for syncing)

  ```ShellSession
  $ fizzy cfg sync
  ```

### Instantiate

Create configuration instances.

#### Usage example

* *Create an instance for each user*

  Here is where the configuration is evaluated and templates are expanded, so we need to be sure that we run the command using the right user and variables.

  ```ShellSession
  $ sudo -u user_a fizzy cfg instantiate --inst-name=user_a --vars-name=vars_a
  $ sudo -u user_b fizzy cfg instantiate --inst-name=user_b --vars-name=vars_b
  ```

### Install

Install a previously created configuration instance into the system.

#### Usage example

* *Install an instance for each user*

  Here some setup could be performed as well (e.g. creating intermediate dirs), so we need to be sure that we run the command using the right user.

  ```ShellSession
  $ sudo -u user_a fizzy sys install --inst-name=user_a --vars-name=vars_a
  $ sudo -u user_b fizzy sys install --inst-name=user_b --vars-name=vars_b
  ```

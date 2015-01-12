Fizzy
=====

The hassle free configuration manager

![Status](http://img.shields.io/badge/status-WIP-yellow.svg)

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
* Ruby
* Thor
then you can drop [fizzy](./fizzy) everywhere (possibly in the system path) and make it executable.

**Contributions are really welcome!**

## Available commands

### Sync

Sync with the remote configuration repository.

This command can be run as a unprivileged user or as root: it makes no difference.

#### Usage example

* *First sync*

  ```ShellSession
  $ fizzy sync --url url_to_config
  ```

* *Other syncs* (there is no need to pass the URL for syncing)

  ```ShellSession
  $ fizzy sync
  ```

### Instantiate

Create configuration instances.

#### Usage example

* *Create an instance for each user*

  Here is where the configuration is evaluated and templates are expanded, so we need to be sure that we run the command using the right user.

  ```ShellSession
  $ sudo -u usera fizzy instantiate --inst-name usera
  $ sudo -u userb fizzy instantiate --inst-name userb
  ```

### Install

Install a previously created configuration instance into the system.

#### Usage example

* *Install an instance for each user*

  Here some setup could be performed as well (e.g. creating intermediate dirs), so we need to be sure that we run the command using the right user.

  ```ShellSession
  $ sudo -u usera fizzy install --inst-name usera
  $ sudo -u userb fizzy install --inst-name userb
  ```

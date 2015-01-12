Fizzy
=====

The hassle free configuration manager

![Status](http://img.shields.io/badge/status-WIP-yellow.svg)

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

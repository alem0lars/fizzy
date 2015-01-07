fizzy
=====

the hassle free configuration manager


## available commands

### sync

sync with the remote configuration repository.

this command can be run as a unprivileged user or as root: it makes no
difference.

#### usage example

* *first sync*

  ```ShellSession
  $ fizzy sync --url url_to_config
  ```

* *other syncs* (there is no need to pass the url for syncing)

  ```ShellSession
  $ fizzy sync
  ```

### instantiate

create configuration instances.

#### usage example

* *create an instance for each user*

  here is where the configuration is evaluated and templates are expanded,
  so we need to be sure that we run the command using the right user.

  ```ShellSession
  $ sudo -u usera fizzy instantiate --inst-name usera
  $ sudo -u userb fizzy instantiate --inst-name userb
  ```

### install

install a previously created configuration instance into the system.

#### usage example

* *install an instance for each user*

  here some setup could be performed as well (e.g. creating intermediate dirs),
  so we need to be sure that we run the command using the right user.

  ```ShellSession
  $ sudo -u usera fizzy install --inst-name usera
  $ sudo -u userb fizzy install --inst-name userb
  ```

# Fizzy bignami
In Italian a *bignami* is a little book with only formulas. In old days when no
smart electronic devices were common, students used *bignami* as a quick and
fast method to remember.

This document has the intent to be used like a *bignami* for fizzy.

# Fizzy - the hassle free configuration manager
fizzy is an easy-to-use, learn-by-doing, lightweight, configuration management
tool meant to be mainly used by developers, hackers and experienced users.

It doesn't seek to reimplement the wheel, instead it follows the unix philosophy
do one thing and do it well making extremely easy to integrate with your 
existing ecosystem.

## Installation
The destination can be everywhere, I suggest `/usr/local/bin` in GNU/Linux 
based systems because it's almost always in the PATH environment variable, 
so you can run fizzy from everywhere.

```
$ curl -sL https://raw.githubusercontent.com/alem0lars/fizzy/master/build/fizzy | \
  sudo tee /usr/local/bin/fizzy > /dev/null && \
  sudo chmod +x /usr/local/bin/fizzy
```

Now prepare fizzy enviroment:

```
$ mkdir ~/.fizzy
$ export FIZZY_DIR=~/.fizzy
```

## Getting Started
Create a repository on GitHub and name it as the desired config, a good pattern
for the name is `<name>-configs`.

Now, let's clone the repo using **fizzy**:
```
$ fizzy cfg s -C <name> -U username/<name>-config
```
As a result of the previous command, **fizzy** cloned the repo to the following
path:
`~/.fizzy/cfg/<name>`

The structure of a *fizzy compliant* configuration should following the follwing
pattern:
```
- <name>
  |
  |-- elems
  |
  |-- vars
  |
  `-- meta.yml
```
Create now the two directories
```
$ mkdir elems vars
```

`elems` contains all the parametrized configuration files `.tt`. Inside `vars`
are kept the parameters that will be used to generate the custom config.

`meta.yml` contains the paths where the configs will be instantiated and which
file `.tt` will be used to generate them.
Here's an example of this file:
```
elems:

- src: ^(zshrc)$
  dst: ~/.<1>
  only: f?zsh


# vim: set filetype=eruby.yaml :
```
The tag `src` specifies which file, inside `elems` folder, should be used. The
tag `dst` specifies where should the file be instantiated in the system.
Finally, `only` tells fizzy whether the file should be instatiated:
depending on the defined *features*: the configuration file will be instantiated
only if `vars` contains a file were it was priorly defined a *feature* matching
the one specified by the tag `only`. Every feature in `only` must be appended to
the string `f?` that stands for *feature*.

## Example of config

For this example we will consider a simple and trivial **git** config.

## meta.yml

**Git** global configuration file is placed inside the user's home folder, so
`~/.gitconfig`.
First of all let's create `meta.yml` so that the config file will be saved
in the correct point inside the home.
```
elems:

  - src: ^(gitconfig)$
    dst: ~/.<1>
    only: f?git


# vim: set filetype=eruby.yaml :
```

### vars

We can now move to `vars` folder to define all the parameters that should be
instantiated inside the config.
It is a good practice to **always** create a file called `generic.yml`
containing all the parameters and features shared by every instances.

Following is a possible example of the `general.yml` file:
```
features:
  - git
  - github

user:
  name: John Doe

# vim: set filetype=eruby.yml :
```

Let's now define a profile which will contain the specific parameters for the
instance that we want to create, create a file called `personal.yml`
```
# => inherits: generic <= #

user:
  username: johndoe
  email: john@doe.com

# vim: set filetype=eruby.yml :
```
The file that was just created contains a *magic comment* interpreted by
**fizzy**. By using *inherits: ...* we are specifying which files we want to
inherit for the current instance.
It is possible to specify multiple files separated by comma as shown below:
```
# => inherits: generic, file1, file2 <= #
...
```
NOTE: the inherited files shouldn't include the extension

#### Creation of a second profile

It is possible to create as many profile as desired; for example, extending the
same **git** config, we also want to create a profile that could be used by
**John Doe** in his workstation. In this case we need a new profile `work.yml`
```
# inherits: genric <= #

user:
  unsername: doejohn123
  email:  doejohn@foo.com
```

### elems

Let's move inside `elems` folder now. The files inside this folder will have the
same syntax of those representing the actual config.
NOTE: the files placed inside this folder, containing the parameters interpreted
by **fizzy** **MUST** end in `.tt`, thus in our case the file should be named
`gitconfig.tt`. If the actual config file already as his own extension, what we
need to do is just to append `.tt` e.g. `dunst.conf.tt`.

Let's proceed now by creating the file `gitconfig.tt`:
```
[user]
  email = <%= get_var! 'user.email' %>
  name = <%= get_var! 'user.email' %>
  username = <%= get_var! 'user.username' %>

[color]
  ui = auto

<% if has_feature? :github %>
[github]
  user = <%= get_var! 'user.username' %>
<% end %>
```
By using the tag `<%= get_var! 'varname' %>`, as shown in the example, we are
asking **fizzy** to replace the tag with the name of the variable priorly
defined in a file contained inside `vars` folder. Taking one more look at the
given example we can also notice that the used variable is `user.email`, the two
parts are separated by a dot because inside `personal.yml` file we defined:
```
user:
  email: john@doe.com
```
thus the dot specifies that email is a subcategory of user.

## Incarnation

At this point we are ready to *incarnate* our config:
```
$ fizzy qi -C git -I git -V personal
```
Now **fizzy** will parse the file and it will create, inside
`~/.fizzy/inst/git/elems`, the files ready to be used, and afterwards it will
add a symbolic link pointing to them inside the filesystem at the location
specified previously in `meta.yml`.

Thanks to the power of **fizzy** we can even instantiate the config containing
the parameters of the work profile in the workstation without having to dismiss
the first configuration:
```
$ fizzy qi -C git -I git -V work
```

Enjoy!

## Sync config

It is necessary to syncronize the repo after any update of the config, to do
this use the following command:
```
$ fizzy cfg sync -C git
```
**fizzy** will ask you which files you want to track, and also to specify a
commit message. At this point in an extremely transparent way, **fizzy** will
commit and push the updates.

## Thanks

* **alem0lars**
* **jake**
  for initial idea and the original bignami,
  available at: https://github.com/jak3/fizzy-bignami

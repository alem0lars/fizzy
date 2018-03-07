# Fizzy bignami

In Italian a *bignami* is a little book with only formulas. In old days when no
smartinor electronic device were common, students use *bignami* like quick and
fast method to remember.

This document has the intent to be used like a *bignami* for fizzy.

# Fizzy - the hassle free configuration manager
fizzy is an easy-to-use, learn-by-doing, lightweight, configuration management
tool meant to be mainly used by developers, hackers, experienced users

It doesn't try to reimplement the wheel, instead it follows the unix philosophy
do one thing and do it well making extremely easy to integrate with your 
existing ecosystem.

## Installazione
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
$ mkdir ~/.fizzy
```

## Getting Started
Creare una repository su GitHub con il nome della config che si vuole 
realizzare, un buon pattern per il nome e' `<name>-configs`.

Ora, utilizzando **fizzy** cloniamo la repo:
```
$ fizzy cfg s -C <name> -U username/<name>-config
```
A seguito di questo comando **fizzy** ha clonato la repo al percorso: 
`~/.fizzy/cfg/<name>`

La struttura di una configurazione *fizzy compliant* e' la seguente:
```
- <name>
  |
  |-- elems
  |
  |-- vars
  |
  `-- meta.yml
```
Creiamo ora le due cartelle:
```
$ mkdir elems vars
```

All'interno della cartella `elems` risiedono tutti i file di configurazione
parametrizzati con estenzione `.tt`, invece nella cartella `vars` risiedono 
i parametri che dovranno essere utilizzati per generare la vera e 
propria config.

Il file `meta.yml` contiene i percorsi in cui dovranno essere istanziate le
config e quali file con estensione `.tt` dovranno essere utilizzati per la
generazione di quest'ultime.
Un esempio di questo file e' il seguente:
```
elems:

- src: ^(zshrc)$
  dst: ~/.<1>
  only: f?zsh


# vim: set filetype=eruby.yaml :
```
Il tag `src` specifica quale file all'inerno della folder `elems` deve essere
utilizzato. Il tag `dst` specifica dove verra' istanziato il file nel sistema.
Infine il tag `only` serve a inidicare selettivamente se questo file dovra'
essere istanziato oppure no: se in uno dei file all'interno di `vars` abbiamo 
definito una `features` che matcha con quella presente in `only`, allora il 
file verra' istanziato, in caso sontrario no. Ogni features nel tag `only` deve 
essere preceduta dalla stringa `f?` a significare *feature*.

## Config di esempio

Per questo esempio prendiamo una semplice e banale config di **git**.

### meta.yml
Il file di configurazione globale di **git** risiede nell home folder dell 
utente, quindi in `~/.gitconfig`.
Come prima cosa prepariamo il file `meta.yml` in modo che il file di config
venga salvato nel punto giusto nella home.
```
elems:

  - src: ^(gitconfig)$
    dst: ~/.<1>
    only: f?git


# vim: set filetype=eruby.yaml :
```
### vars
Ora ci spostiamo nella cartella `vars` e andiamo a definire tutti i parametri
che dovranno essere istanziati nella config.
All'interno della cartella `vars` e' bene definire **sempre** un file chiamato
`generic.yml` in cui si definiscono i parametri efeatures comuni a tutte le 
diverse istanze.

Un esempio di `general.yml` potrebbe essere il seguente:
```
features:
  - git
  - github

user:
  name: John Doe

# vim: set filetype=eruby.yml :
```

Andimo ora a definire un profilo che conterra' i parametri specifici per 
l'istanza che vogliamo creare, quindi creiamo un file `personal.yml`
```
# => inherits: generic <= #

user:
  username: johndoe
  email: john@doe.com

# vim: set filetype=eruby.yml :
```
Il file appena creato contiene un *magic comment* che **fizzy** interpreta, 
mediante *inherits: ...* specifichiamo quali file vogliamo ereditare per 
l'istanza corrente.
E' possibile specificare piu' file separandoli da virgola in questo modo:
```
# => inherits: generic, file1, file2 <= #
...
```
NB: non bisogna spcificare l'estensione dei file che si vogliono ereditare.

#### Creazione di un altro profilo
E' possibile creare quanti profili si vogliono; per esempio, sfruttando sempre 
la config di **git**, vogliamo realizzare anche un profilo che potrebbe servire 
a **John Doe** nella sua postazione di lavoro. In questo caso creamo un nuovo 
profilo `work.yml`
```
# inherits: genric <= #

user:
  unsername: doejohn123
  email:  doejohn@foo.com
```

### elems

Spostiamoci ora nella cartella `elems`. Qui saranno presenti tutti i file 
con sintassi corrispondente a quella della vera e propria config. 
NB: i file preseni in questa cartella che contengono i parametri che **fizzy** 
dovra' interpretare **DEVONO** avere estensione `.tt`, quindi nel nostro caso il
 file dovra' avere questo nome `gitconfig.tt`. Se invece il file di 
 configurazione ha gia' una sua estensione, quello che si dovra' fare e' 
semplicemente appendere l'estensione `.tt` quindi per esempio `dunst.conf.tt`.

Procediamo ora a creare il file `gitconfig.tt`:
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
Come si puo' osservare dall'esempio con il tag `<%= get_var! 'varname' %>`
si chiede a **fizzy** di poter sostituire al tag il nome della variabile 
definita in precedeza in un file presente nella cartella `vars`. Inoltre 
nell'esempio proposto si puo' osservare che la variabile a cui facciamo 
riferimento e' `user.email`, la separazione con il punto e' dovuta al fatto 
che nel file `personal.yml` abbiamo definito:
```
user:
  email: john@doe.com
```
e quindi il punto serve a separare le categorie.

## Incarnazione
A questo punto siamo pronti per poter *incarnare* la nostra config:
```
$ fizzy qi -C git -I git -V personal
```
A questo punto **fizzy** effettuera' il parsing del file e creera' all'interno 
della cartella `~/.fizzy/inst/git/elems` i file pronti per essere usati e 
successivamente effettuera' un link simbolico alla posizione nel filesystem 
specificata il precedenza nel file `meta.yml`.

Sfruttando la potenza di **fizzy** possiamo istanziare la config con i parametri
 del profilo lavorativo nella postazione di lavoro manenendo anche la precedente
 configurazione:
```
$ fizzy qi -C git -I git -V work
```

Enjoy!

## Sync della config
A seguito di modifiche della config e' necessario poter sincronizzare la repo, 
per fare questo usare il comando:
```
$ fizzy cfg sync -C git
```
**fizzy** vi chiedera' quali file volete tracciare e vi chiedera' di specificare 
un messaggio di commit. A questo punto in maniera estremamente trasparente, 
**fizzy** effettuera' il commit e push delle modifiche.

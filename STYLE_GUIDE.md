# Style Guide

## Source code

* **2-space** indentation.
* **Use double-quotes** (`"`) instead of single-quotes (`'`).
* **No strict rule about indentation**: the best indentation is the one that
  makes your *code more readable*, but the general guideline is to align with
  the previous line.
* **(Right-)Align operators** and assignments *within the same block*.
* Prefer **compact declaration** of modules and classes instead of the
  **indented** style.
* Run `bundle exec rake lint` to perform some automatic checks.

## Specs

* Follow the [betterspecs guidelines][betterspecs] (*very important!*).
* Use as **few** parenthesis as possible.
* The tests results must be **human readable**.
* Run `bundle exec rake lint` to perform some automatic checks.

## Get help

Open a new issue using `enhancement`, `question`, `help-wanted` labels to
request some help to make your code look prettier.


<!-- Link declarations -->

[betterspecs]: http://betterspecs.org

# Contributing

We love pull requests from everyone. By participating in this project, you agree
to abide by the [Code of Conduct][code_of_conduct].

## Code changes

### 1: Prepare

- Fork, then clone the repo: `git clone git@github.com:your-username/fizzy.git`.
- Set up Ruby dependencies via Bundler: `bundle install`.
- Make sure the tests pass: `bundle exec rake docker:test`.

### 2: Make changes

- Make your change.
- Follow the [Style Guide][style_guide].
- Make the tests pass: `bundle exec rake docker:test`.
- If you need to open a console inside the Docker container, you can run:
  `bundle exec rake docker:console`.
- Update the packages: `bundle exec rake package`.
- Add notes on your change to the [changelog][changelog] file,
  in the `Next Version` section.
- Write a [good commit message][good_commit_message].
- Push to your fork.

### 3: Integrate changes

- [Submit a pull request][send_pull_request].

## Issues

There are some simple rules to keep in mind when you want to open a new issue:

* Use the pre-filled template
* Assign the issue to you if/when you start/plan to solve it
* There are many labels. You need to apply the right ones:
  * **Categorization labels:**
    * `bug`: used to report a defect, something that isn't working correctly.
    * `enhancement`: used to report a possible improvement on a existing feature.
    * `feature`: used to add/discuss a new feature.
  * **State labels:**
    * `help wanted`: anyone can assign himself to that label and is free to contribute as much as he wants.
    * `ready`: the issue has been discussed and is ready to be assigned.
      Please keep in mind that ONLY issues with label `ready` can be implemented and solved.
      Instead, any issue can be discussed/modified.
    * `invalid`: The issue is incorrect. It won't be solved.
    * `duplicate`: The issue has already been reported. It won't be solved, but instead ONLY the original
      issue will advance.
    * `question`: The issue is strongly open for discussion. People is encouraged to express their opinion and
      discuss about it (using comments).
      When an issue is in that stage, any kind of intellectual contribution is appreciated, in particular
      personal opinions, vision, point-of-views.

## Changelog entry format

Here are a few examples:

```
* [#716](https://github.com/bbatsov/rubocop/issues/716): Fixed a regression in the auto-correction logic of `MethodDefParentheses`. ([@bbatsov][])
* New cop `ElseLayout` checks for odd arrangement of code in the `else` branch of a conditional expression. ([@bbatsov][])
```

* Mark it up in [markdown syntax][markdown_syntax].
* The entry line should start with `* ` (an asterisk and a space).
* If the change has a related GitHub issue (e.g. a bug fix for a reported issue), put a link to the issue as `[#123](https://github.com/alem0lars/fizzy/issues/1): `.
* Describe the brief of the change. The sentence should end with a punctuation.
* At the end of the entry, add an implicit link to your GitHub user page as `([@username][])`.
* If this is your first contribution to fizzy project, add a link definition for the implicit link to the bottom of the changelog as `[@username]: https://github.com/username`.

## FAQ

### Q: Certificates errors on Windows

If you're developing with Windows you may encounter errors about certificates
that can't be verified.

To fix:

1. Download the pem file from: https://curl.haxx.se/ca/cacert.pem
2. Set the environment variable `SSL_CERT_FILE` to point to the downloaded file

----

**Thank you for your contribution!**


<!-- Link declarations -->

[style_guide]: ./STYLE_GUIDE.md
[code_of_conduct]: ./CODE_OF_CONDUCT.md
[changelog]: ./CHANGELOG.md

[send_pull_request]: https://github.com/alem0lars/fizzy/compare

[houndci]: https://houndci.com

[good_commit_message]: ./COMMIT_MESSAGE_FORMAT.md

[markdown_syntax]: http://daringfireball.net/projects/markdown/syntax

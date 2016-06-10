# Contributing

We love pull requests from everyone. By participating in this project, you agree
to abide by the [Code of Conduct][code_of_conduct].

## 1: Prepare

- Fork, then clone the repo: `git clone git@github.com:your-username/fizzy.git`
- Set up Ruby dependencies via Bundler: `bundle install`
- Make sure the tests pass: `rake test`

## 2: Make changes

- Make your change.
- Write tests.
- Follow the [Style Guide][style_guide].
- Make the tests pass: `rake test`
- Update the packages: `rake package`
- Add notes on your change to the [CHANGELOG.md][changelog] file,
  in the `Next Version` section.
- Write a [good commit message][good_commit_message].
- Push to your fork.

## 3: Integrate changes

- [Submit a pull request][send_pull_request].
- If [Hound CI][houndci] catches style violations, fix them.

----

**Thank you for your contribution!**

<!-- Link declarations -->

[style_guide]: ./STYLE_GUIDE.md
[code_of_conduct]: ./CODE_OF_CONDUCT.md
[changelog]: ./CHANGELOG.md

[send_pull_request]: https://github.com/alem0lars/fizzy/compare/

[houndci]: https://houndci.com

[good_commit_message]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

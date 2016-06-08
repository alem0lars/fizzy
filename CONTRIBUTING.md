# Contributing

We love pull requests from everyone. By participating in this project, you agree
to abide by the [Code of Conduct](./CODE_OF_CONDUCT.md).

## 1: Prepare

- Fork, then clone the repo: `git clone git@github.com:your-username/fizzy.git`
- Set up Ruby dependencies via Bundler: `bundle install`
- Make sure the tests pass: `rake test`

## 2: Make changes

- Make your change.
- Write tests.
- Follow our [Style Guide](./STYLE_GUIDE.md).
- Make the tests pass: `rake test`
- Update the packages: `rake package`
- Add notes on your change to the `CHANGELOG.md` file,
  in the `Next Version` section.
- Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
- Push to your fork.

## 3: Integrate changes

- [Submit a pull request](https://github.com/alem0lars/fizzy/compare/).
- If [Hound](https://houndci.com) catches style violations, fix them.

----

**Thank you for your contribution!**

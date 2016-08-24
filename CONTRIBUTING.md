# Contributing

We love pull requests from everyone. By participating in this project, you agree
to abide by the [Code of Conduct][code_of_conduct].

## Code changes

### 1: Prepare

- Fork, then clone the repo: `git clone git@github.com:your-username/fizzy.git`.
- Set up Ruby dependencies via Bundler: `bundle install`.
- Make sure the tests pass: `rake test`.

### 2: Make changes

- Make your change.
- Write tests.
- Follow the [Style Guide][style_guide].
- Make the tests pass: `rake test`.
  You can also run tests inside a Docker container, running: `rake docker:test`.
  To forcibly build the Docker image, you need to set the environment variable
  `FIZZY_DOCKER_BUILD` to `true`: `FIZZY_DOCKER_BUILD=true rake docker:test`.
- If you need to open a console inside the Docker container, you can run:
  `rake docker:console`.
- Update the packages: `rake package`.
- Add notes on your change to the [CHANGELOG.md][changelog] file,
  in the `Next Version` section.
- Write a [good commit message][good_commit_message].
- Push to your fork.

### 3: Integrate changes

- [Submit a pull request][send_pull_request].
- If [Hound CI][houndci] catches style violations, fix them.

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

----

**Thank you for your contribution!**

<!-- Link declarations -->

[style_guide]: ./STYLE_GUIDE.md
[code_of_conduct]: ./CODE_OF_CONDUCT.md
[changelog]: ./CHANGELOG.md

[send_pull_request]: https://github.com/alem0lars/fizzy/compare/

[houndci]: https://houndci.com

[good_commit_message]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

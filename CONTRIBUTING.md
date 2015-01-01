# How to Contribute

We welcome outside contributions to the project. Here are some guidelines to follow to help ensure a smooth process.

## Contribution Tasks

* Reporting Issues
* Making Code Changes
* Submitting Changes (Pull Requests)
* Reviewing and Merging Changes

### Reporting Issues

* Make sure you have a [GitHub account](https://github.com/signup/free)
* Submit a [Github issue](./issues) by:
  * Clearly describing the issue
    * Provide a descriptive summary
    * Explain the expected behavior
    * Explain the actual behavior
    * Provide steps to reproduce the actual behavior

### Making Code Changes

* Fork the repository on GitHub
* Create a topic branch from where you want to base your work (usually 'master')
  * To quickly create a topic branch based on master; `git branch feature/myfix master`
  * Then checkout the new branch with `git checkout feature/myfix`.
  * Please avoid working directly on the `master` branch.
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are [well formed](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
* If there is a corresponding issue, you can close it by including "Closes #issue" or "Fixes #issue" in your commit message. See [Github's blog post for more details](https://github.com/blog/1386-closing-issues-via-commit-messages)
* Make sure you have added the necessary tests for your changes.
* Run _all_ the tests to assure nothing else was accidentally broken.

### Submitting Changes (Pull Requests)

* Read the article ["Using Pull Requests"](https://help.github.com/articles/using-pull-requests) on GitHub.
* Make sure your branch is up to date with its parent branch (i.e. master)
  * `git checkout master`
  * `git pull --rebase`
  * `git checkout <your-branch>`
  * `git rebase master`
  * It is likely a good idea to run your tests again.
* Push your changes to a topic branch in your fork of the repository.
* Submit a Pull Request from your fork to the project.

### Reviewing and Merging Changes

* It is considered "poor form" to merge your own Pull Request.
* Please take the time to review the changes and get a sense of what is being changed. Things to consider:
  * Does the commit message explain what is going on?
  * Does the code changes have tests? _Not all changes need new tests, some changes are refactorings_
  * Does the commit contain more than it should? Are two separate concerns being addressed in one commit?
  * Did the Travis tests complete successfully?
* If you are uncertain, bring other contributors into the conversation by creating a comment that includes their @username.
* If you like the Pull Request, but want others to chime in, create a +1 comment and tag a user.

# Additional Resources

* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
* [Pro Git](http://git-scm.com/book) is both a free and excellent book about Git.
* [A Git Config for Contributing](http://ndlib.github.io/practices/my-typical-per-project-git-config/)

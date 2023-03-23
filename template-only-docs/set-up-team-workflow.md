# Set up development workflow

## Pull request template

If desired, update the [pull request template](../.github/pull_request_template.md).

## Branch protections

Once [CI is set up](./set-up-ci.md), consider [adding branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/managing-a-branch-protection-rule) for the `main` branch.

Recommended settings:

* Require pull request before merging
* Require minimum of 1 approval
* Require CI status checks to pass before merging
* Require branches to be up to date before merging

*Some projects choose to dismiss stale pull request approvals when new commits are pushed but note that this makes it more difficult for PR authors to address nits and non-blocking suggestions.

## Pull request settings

Update pull request settings in Settings > General > Pull Requests.

Recommended settings:

* Only allow squash merging. This keeps the main branch history clean and easy to read, which is particularly useful for deploys and generating release notes. Default commit message to pull request title and description to encourage more consistent commit messages.
* Always suggest updating pull request branches. This encourages pull requests to be updated when they deviate from `main`.
* Automatically delete head branches. This helps prevent remote branches from proliferating.

## Collaborators

In Settings > Collaborators, add all collaborators that should have access to the git repo

## Code security and analysis

After you've added the templates to your repo, enable GitHub's security features:

In Settings > Code security and analysis, enable the following features:

- Dependabot
  - Dependabot alerts
  - Dependabot security updates
  - Dependabot version updates - follow GitHub's setup flow for configuring Dependabot
- Code scanning
  - CodeQL analysis - follow GitHub's flow for configuring CodeQL. The "Default" set up option is typically all that's needed for JS and Python codebases.
- Secret scanning

## Other Github features

In Settings > General > Features, enable/disable features that you want for your project. For example, turn off the Wiki if your project won't be using it

## Documenting GitHub settings

After setting up your project, consider copying this document into your project's `docs/` folder to document your team's settings. It could serve as a reference for people on the team that do not have admin access to the GitHub repository as well as explain the rationale behind certain settings.

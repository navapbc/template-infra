# Contributing to Nava Strata

Thank you for your interest in contributing to Nava Strata! Strata is a
gold-standard target architecture and suite of open source tools that gives
government agencies everything they need to run a modern service. We welcome
contributions from developers, designers, policy experts, and community members.
This document outlines how members of the community should approach the
contribution process.

## Community

We are committed to providing a welcoming environment for all contributors. All
contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Bugs and issues

Bug reports are welcome, as they make Strata better for everyone who uses it.
Create a GitHub issue using the bug template to make sure it contains the
necessary information for us to triage the issue. Prior to filing an issue,
please search the existing issues to make sure it is not a duplicate.

If the issue is related to security, please email us directly at
<strata@navapbc.com>.

## Getting started

**Every contribution starts with an issue**. Before writing any code or opening
a pull request (PR):

1. Open a new issue describing what you'd like to work on, or comment on an
   existing issue for the work you are interested in.
1. Wait for agreement. Discuss the work with a maintainer so we're aligned on
   scope and direction.
1. Get assigned. Once we agree, a maintainer will assign the issue to you.
1. Then start coding. Only open a PR for an issue that is assigned to you. Post
   regular status updates to the issue if the work will take longer than a day.

No assigned issue = no PR. Pull requests without a corresponding issue with be
closed.

This keeps everyone on the same page, avoids wasted efforts on changes that may
not fit the project's direction, and prevents multiple contributors from working
on the same thing.

See [the development docs](./template-only-docs/template-development.md) for
details on technical setup and development workflow.

## Finding where to pitch in

Maintainers label issues that would be good for first-time contributors with
["workflow: good first issue"][w: gfi]. These issues should not require a lot of
context on the project itself and any details should be clearly laid out in the
issue, though in some cases they may require some familiarity with tooling or
ecosystems used by the project.

After you are comfortable with the development setup and process, issues labeled
with ["workflow: self-contained"][w: sc] are the next best place to start. These
will vary in size and complexity, but will be relatively isolated in scope and
should not require grasping complex interactions or architectural details.

That's not to say these are the only issues you can look at, but these should be
the lowest friction starts. Always follow the guidance in the previous section
for indicating interest and getting assigned before starting work on any issue.

Beyond the previous labels, [general bugs][bugs] often can use more hands.
Anything labeled with "workflow: needs refinement" should be avoided.

[w: gfi]: https://github.com/navapbc/template-infra/issues?q=state%3Aopen%20label%3A%22workflow%3A%20good%20first%20issue%22
[w: sc]: https://github.com/navapbc/template-infra/issues?q=state%3Aopen%20label%3A%22workflow%3A%20self-contained%22
[bugs]: https://github.com/navapbc/template-infra/issues?q=state%3Aopen%20type%3ABug

## Submitting changes

1. Push your changes up to GitHub
   - If you have write access to the repo, push your changes to a branch on the
      repo itself with the naming convention `<your username>/<issue
      number>-<short title>` (e.g., `johndoe/432-add-widget` for a user
      `johndoe` related to Issue 432 whose title might be "Add widget to
      homepage")
   - If you do not have write access to the repo, push your changes to a branch
     on your fork on GitHub
1. Create a pull request on GitHub
   - Use a clear and descriptive title
   - Fill out the PR template completely
   - PRs should generally get auto-assigned reviewers, but feel free to
     explicitly request a review from the maintainer that assigned you the
     issue.
1. Wait for review. Maintainers will review your PR and may request changes.

### PR Guidelines

Write a good title and description. Explain _why_ the changes are being made in
the way they are (most of this can hopefully come from the associated issue or
discussion on it). Reference related issues.

Write reviewable code. Generally try to keep changes small and focused on one
thing. Follow a "one idea is one commit" approach. If you find yourself using
words like "and" or "also" in your title that might mean the changes could be
broken down better. You can create multiple PRs for a single issue to attack it
in pieces. Sometimes large PRs are unavoidable, but they should be the exception
not the rule.

It's okay to open a PR early before everything is "done"! Especially when you've
encountered a decision point that hadn't been discussed before, or you are just
unsure about some aspect of the changes. Put the PR in the "draft" state and
call out the particular areas you are looking for feedback on. Maintainers can
then do a quicker and focused review on just those things to unblock you. Once
the changes are complete/ready for a full review, move the PR out of "draft".

Summary:

- PRs should implement one thing/feature/fix
- Add/update documentation
- Add tests for new functionality
- Ensure all automated checks (linting/tests/etc.) pass
- Provide before/after screenshots for visual changes

### Code Review Criteria

Reviewers will check for:

- **Functionality**: Does the code work as intended?
- **Security**: Are there any security vulnerabilities?
- **Performance**: Will this impact system performance?
- **Accessibility**: Does this maintain accessibility standards?
- **Maintainability**: Is the code readable and maintainable?
- **Testing**: Are there adequate tests?

They will communicate in accordance with the [Code of
Conduct](CODE_OF_CONDUCT.md) and:

- Address the work itself, not the person contributing
- Clearly indicate where feedback is a nitpick/nice-to-have vs
  blocking/requirement
- Provide context and rationale for suggested changes

### Addressing Feedback

- Respond (reasonably) promptly to review comments. PRs that go days/weeks
  without followup will be closed and author may be blocked if there develops a
  trend of abandoned work.
- Make requested changes or discuss alternatives. Reviewers will distinguish
  blocking and non-blocking feedback.
- Update PR title and description based on change (if needed)
- Re-request review after making changes

### Approval

Once the PR is approved, it needs to be merged:

- If you have write access to the repo, it's your responsibility to merge your
  PR and track any triggered builds/CI for issues (where possible).
- If you do not have write access to the repo, a maintainer will merge your PR.
  You are still generally responsible for issues that might arise from the
  changes after they are merged! A maintainer might reach out.

---

Thank you for contributing to Nava Strata!

# Updates

## Prerequisites

* The [update script](/template-only-bin/update-template.sh) assumes that your project is version-controlled using `git`. The script will edit your project files, but it will not run `git commit`. After running the script, use `git diff` to review all changes carefully.

## Instructions

To update your project to a newer version of this template, run the following command in your project's root directory:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- <APP_NAMES>
```

`<APP_NAMES>` is a required argument. It must be a comma-separated list (no spaces) of the apps in `/infra`. App names must be hyphen-separated (i.e. kebab-case). Examples: `app`, `app,app2`, `my-app,your-app`.

**Remember:** Read the release notes in case there are breaking changes you need to address.

### Specifying a branch, a commit, or a tag

By default, the update script will apply changes from the `main` branch of this template repo. If you want to update to a different branch, a specific commit, or a specific tag (e.g. a release tag), run this instead:

```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- <APP_NAMES> <TARGET_VERSION> <TARGET_VERSION_TYPE>
```

`<TARGET_VERSION>` should be the version of the template to install. This can be a branch, commit hash, or tag.

`<TARGET_VERSION_TYPE>` should be the type of `<TARGET_VERSION>` provided. Defaults to `branch`. This can be: `branch`, `commit`, or `tag`.

### Examples

If your project has one application named `app` and you want to update it to the `main`  branch of this template repo, run:
```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- app
```

If your project has two applications named `app, app2` and you want to update to the commit `d42963d007e55cc37ef666019428b1d06a25cf71`, run:
```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- app,app2 d42963d007e55cc37ef666019428b1d06a25cf71 commit
```

If your project has three applications named `foo,bar,baz` and you want to update to the `v.0.8.0` release tag, run:
```bash
curl https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/update-template.sh | bash -s -- foo,bar,baz v0.8.0 tag
```

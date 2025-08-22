# Rename an application

The exact process may depend on your particular needs, but the cleanest way to
"rename" the app, is to create a copy of it under the new name, migrate
data/domains, then destroy the old app.

Alternatively, if you can tolerate more downtime, you can teardown the old app
first, then spin up the new app, effectively the reverse order described here.

The application name is used by a variety of conventions in the infrastructure
code to tie things together that make it a little difficult to say, only rename
the source code directory, not to mention the potential confusion.

And the app name is used in resource identifiers, which can't easily be
overridden at this point. So if you just `s/<OLD_APP_NAME>/<NEW_APP_NAME>/g` and
tried to update the existing infra, a lot of stuff will be deleted and
recreated, possibly 

# Clone existing application

- Run `nava-platform infra add-app . <NEW_APP_NAME>`
- Run `nava-platform app install --template-uri <template> . <NEW_APP_NAME>` for
  each application template used by `<OLD_APP_NAME>`.
  - Alternatively, copy `.template-application-*/<OLD_APP_NAME>.yml` to
    `.template-application-*/<NEW_APP_NAME>.yml` and run `nava-platform app
    update --force --no-commit . <NEW_APP_NAME>`
- Copy `infra/<OLD_APP_NAME>/app-config/` to `infra/<NEW_APP_NAME>/app-config/`
  - And any other infra code modifications you know exist for the old app, in
    general it should just be config changes, but you can diff the directories
    to get a sense of any other differences.
- Copy `<OLD_APP_NAME>/` to `<NEW_APP_NAME>/`

./add-application.md

# Migrate/Switchover


# Remove old application

Diff old app code with new copy, migrate any code changes that might have come
in.

./remove-application.md

# Support services that run externally hosted container images

- Status: proposed
- Deciders: <!-- infra maintainers -->
- Date: 2026-09-23

Technical Story: [#1024](https://github.com/navapbc/template-infra/issues/1024)

## Context and Problem Statement

The template assumes every service builds its own image and pushes it to an
ECR repository the template also creates. Some services do not: they run a
third-party image (`flowable`, `nginx`, a vendor's published container) at a
pinned tag. That case technically works today, but only by fighting the
template -- `image_repository_arn` and `image_repository_url` are required,
and the CI/CD pipeline assumes a build step exists.

How should a service declare that its image comes from somewhere the template
does not manage, so that Terraform, IAM, and CI/CD all behave correctly?

## Decision Drivers

- A service using an external image must not require a build repository to
  exist, nor a `make infra-update-app-build-repository` run.
- IAM must stay least-privilege. The ECR pull grant is scoped to a specific
  repository ARN; for public or third-party images there is no such ARN to
  scope to, and the grant should be omitted rather than widened to `*`.
- CI/CD must skip build and publish without those becoming "skipped" red
  herrings in the GitHub UI, and PR environments must still work.
- Existing projects must be unaffected. This is a template many downstream
  repos inherit, so the default path cannot change shape.
- Whatever shape is chosen has to work for Azure too, where the analogous
  variable is `image_registry_id` and the DB role manager is itself a
  container in an internal registry.

## Considered Options

1. **An app-config boolean**, e.g. `has_build_repository = false`, with users
   then setting `infra/{app_name}/service/main.tf` values directly or through
   additional app-config options.
2. **Allow `build_repository_config` to be null**, signalling there is no
   build, with separate top-level outputs for the image repository URL and
   tag that default to the values derived from `build_repository_config`.

## Decision Outcome

Chosen option: **option 2, nullable `build_repository_config` with separate
image outputs**, because it keeps a single source of truth for "where does the
image come from" and makes the null case structurally impossible to get half
right.

The core problem with option 1 is that a boolean and the values it guards can
disagree. `has_build_repository = false` with a stale `repository_arn` still
present in config is a valid-looking state that produces a broken IAM policy.
With option 2 the absence of the config _is_ the signal, so there is no second
field to keep in sync.

### Proposed shape

`app-config` gains an explicit image source, with `build_repository_config`
becoming null when the image is external:

```terraform
# infra/{{app_name}}/app-config/build_repository.tf
locals {
  # null when the service runs an image this project does not build
  build_repository_config = var.image_source == "external" ? null : {
    name           = local.image_repository_name
    # ... unchanged
  }

  # Always populated. Derived from build_repository_config when the project
  # builds its own image; set explicitly when it does not.
  image_config = coalesce(var.external_image_config, {
    repository_url = local.build_repository_config.repository_url
    repository_arn = local.build_repository_config.repository_arn
    tag            = null  # resolved per-deploy from the commit hash
  })
}
```

The service layer then reads `image_config` rather than reaching into
`build_repository_config`:

```terraform
# infra/{{app_name}}/service/main.tf
image_repository_arn = local.image_config.repository_arn  # null when external
image_repository_url = local.image_config.repository_url
image_tag            = coalesce(local.image_config.tag, var.image_tag)
```

### IAM

`infra/modules/service/access_control.tf:58-66` currently emits the
`ECRPullAccess` statement unconditionally against `var.image_repository_arn`.
It becomes conditional, following the pattern already used for `SecretsAccess`
immediately below it:

```terraform
dynamic "statement" {
  for_each = var.image_repository_arn != null ? [1] : []
  content {
    sid = "ECRPullAccess"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [var.image_repository_arn]
  }
}
```

This `dynamic`/`for_each` pattern was verified against the AWS provider: with
the ARN null the `ECRPullAccess` statement is absent from the rendered policy
JSON entirely, and with it set the statement appears as before.

`image_repository_arn` gains `default = null`. Note this is only correct for
_public_ external images. An external image in a private registry needs
registry credentials, which is a separate concern and is listed as out of
scope below.

### CI/CD

`build-and-publish.yml` already has the right seam: it checks whether an image
is published and skips the build steps if so
(`.github/workflows/build-and-publish.yml:75-90`). The change is to short-
circuit earlier, when the app has no build repository at all, so the workflow
is not called rather than called and skipped.

`deploy.yml` calls `database-migrations.yml`, which in turn calls
`build-and-publish.yml`. That chain needs a condition at the top rather than
three independent guards.

### Positive Consequences

- One source of truth. "Is there a build repository" and "what is the image
  URL" cannot disagree.
- The IAM change follows a pattern already present in the same file, so it
  should read as idiomatic to reviewers.
- The same `image_config` indirection works for Azure's `image_registry_id`,
  keeping the two templates structurally aligned.

### Negative Consequences

- `build_repository_config` becoming nullable is a breaking change for any
  downstream project that reads it directly rather than through the service
  layer. Needs a note in the template migration docs.
- `coalesce` on an object requires all branches to have identical attribute
  types, which is finicky in Terraform and will need care.
- More indirection in app-config, which is already the most indirect part of
  the template.

## Pros and Cons of the Options

### Option 1: app-config boolean

- Good, because it is the smallest diff and the most obvious to read.
- Good, because booleans are easy to thread through workflow `if:` conditions.
- Bad, because the boolean and the config it guards can contradict each other,
  and nothing detects that.
- Bad, because it pushes users toward editing `service/main.tf` directly,
  which the template otherwise treats as generated.

### Option 2: nullable `build_repository_config`

- Good, because absence is the signal; there is no redundant flag.
- Good, because it extends naturally to Azure.
- Bad, because nullable object types in Terraform are awkward, particularly
  with `coalesce`.
- Bad, because it is a breaking change for direct consumers of
  `build_repository_config`.

## Out of Scope

Per the issue:

- Having the build-repository layer detect that a service needs no repository
  and skip resource creation. The DB layer does not do this either.
- Transparently caching external images into an internal repository.

Additionally, identified while writing this:

- **Private external registries.** Everything above assumes the external image
  is publicly pullable. Private third-party registries need credentials in
  Secrets Manager and a `repositoryCredentials` block on the task definition.
  That is a distinct piece of work and should get its own issue.

## Validation

The issue asks for test coverage via a new service in `platform-test` pointing
at a simple hello-world image. That should be part of the implementation PR,
not this spec. Suggested: `public.ecr.aws/nginx/nginx` at a pinned tag, which
is publicly pullable and needs no credentials -- keeping the test aligned with
what this design actually supports.

## References

- [#1024](https://github.com/navapbc/template-infra/issues/1024)
- [#772](https://github.com/navapbc/template-infra/issues/772) -- review of
  the older customization PR
- [#474](https://github.com/navapbc/template-infra/pull/474) -- closed PR that
  first added non-custom image support, source of the IAM pattern above
- [#539](https://github.com/navapbc/template-infra/issues/539)

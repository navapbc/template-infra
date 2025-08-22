# Remove an application

To decommission an existing application that has been running.

TODO sections?
Prep
Destroy infra
Delete code
Cleanup

1. Disable the app CI/CD workflows (at least the parts that deploy infra).
  - Could alternatively run `nava-platform infra update-app --answers-only
    --data app_has_dev_env_setup=false . <APP_NAME>` or just delete them, but
    feels cleaner to disable them out-of-bounds and remove the files with
    everything else later.
  - `CI <APP_NAME> PR Environment Checks`
  - `Deploy <APP_NAME>`
  - `CI Infra Service Checks - <APP_NAME>`
1. Run `CI <APP_NAME> PR Environment Destroy` actions for any existing PRs
1. Destroy the `app` infrastructure in every environment
  - /docs/infra/destroy-infrastructure.md
1. Remove app from `infra/networks.tf`
  - TODO or delete `.template-infra/app-<APP_NAME>.yml` and run `nava-platform
    infra update --force .`?
1. Remove related things from `project-config/networks.tf`, like certificates
   configured for the application
1. Then run `make infra-update-network NETWORK_NAME=<NETWORK_NAME>` for every
   network the app was a part of.
1. Delete the code
  - `/infra/<APP_NAME>` (the application infra code)
  - `/<APP_NAME>` (the application source code)
  - Relevant files in `/.template-*/` (template state)
  - Relevant files in `/.github/workflows/`
  - Relevant files in `/docs/`
  - Any other files created by any templates used for the application
1. Remove any external DNS records, delete manually created secrets/certificates/keys

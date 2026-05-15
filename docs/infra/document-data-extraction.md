# Document Data Extraction

The Document Data Extraction feature (abbreviated as DDE) sets up resources for
identifying and extracting data from "documents" (image and PDF files primarily
composed of written information).

## Enable feature in application config

In your application's `app-config` module
(`/infra/<APP_NAME>/app-config/main.tf`), set:

```terraform
enable_document_data_extraction = true
```

Tweak settings as desired in
`/infra/<APP_NAME>/app-config/env-config/document_data_extraction.tf`, notably
the `blueprints` item (see the next section for more info).

Then update the service layer to create the resources:

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

## Custom blueprints

The DDE module utilizes AWS's Bedrock Data Automation (BDA) service, which
supports "blueprints" for fine-tuning some data extraction logic. See the [AWS
docs][bda-blueprint-docs] for more info on use case and structure.

The DDE module has flexible support for loading these blueprints via either
project source files or pre-built blueprints from the AWS catalog.

By default things are set up to load any files in the directory
`/infra/<APP_NAME>/service/document-data-extraction-blueprints/` as custom
blueprints. You can change this location, or add AWS catalog blueprints via
their ARN in the `blueprints` config list in
`/infra/<APP_NAME>/app-config/env-config/document_data_extraction.tf`.

[bda-blueprint-docs]: https://docs.aws.amazon.com/bedrock/latest/userguide/bda-blueprint-info.html

## Updating blueprints

Due to [underlying provider
limitations](https://github.com/navapbc/template-infra/issues/1027), when
specifying blueprints to use, the BDA project resource will always show a (hard
to understand) diff between the IaC and current state.

To eliminate this noise (and facilitate a useful automated checks like
`/.github/workflows/check-infra-deploy-status.yml`), changes to the list of
blueprints are currently ignored. This means the usual:

- Changes to blueprints in AWS console (or other means) won't be detected by
  Terraform
- Additions or removals of blueprints in the config won't apply with other
  service-layer changes (after initial creation)

So after initial creation, if you wish to change the blueprints (or more
generally, sync the deployed state to what is specified in the IaC), you will
need to take a few extra steps:

1. Update `blueprints` config item as appropriate
   - For initial development, commit the changes now. For releases, checkout the
     commit corresponding to the release with the desired changes.
1. Comment out `custom_output_configuration.blueprints` line in the
   `ignore_changes` block on `awscc_bedrock_data_automation_project` in the [DDE
   module][dde-module].
   - Run `sed -i.bak 's/custom_output_configuration.blueprints/# custom_output_configuration.blueprints/' infra/modules/document-data-extraction/resources/main.tf`
1. Update the service to apply the blueprint changes
   - Run `make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>`
1. Uncomment `custom_output_configuration.blueprints` line in the [DDE
   module][dde-module] to restore the silencing.
   - Could achieve this simply by discarding changes in version tracking, e.g.
     in git with `git reset --hard HEAD`, or restore the `*.bak` file created
     via the `sed` example command above.

This means deploying releases with blueprint updates will need manual handling
for the service layer, similar to most other non-service layers. Depending on
timeline of upstream Terraform provider fixes and feedback on if the manual
process is burdensome or not, could develop greater automation around this.

If you don't use the `check-infra-deploy-status.yml` workflow and/or are
expecting frequent changes to the needed blueprints, you could remove the
`ignore_changes` block so that changes take effect via the regular deployment
process.

[dde-module]: /infra/modules/document-data-extraction/resources/main.tf

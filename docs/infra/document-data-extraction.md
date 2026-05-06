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
specifying blueprints to use, the BDA project resource will always show a diff
between the IaC and current state.

To eliminate this noise (and facilitate a useful automated checks like
`/.github/workflows/check-infra-deploy-status.yml`), changes to the list of
blueprints are currently ignored. So after initial creation, if you wish to
change the blueprints, you will need to take a few extra steps:

1. Update `blueprints` config item as appropriate
1. Comment out `custom_output_configuration.blueprints` line in the from the
   `ignore_changes` block on `awscc_bedrock_data_automation_project` in the [DDE
   module][dde-module].
1. Update the service (`make infra-update-app-service APP_NAME=<APP_NAME>
   ENVIRONMENT=<ENVIRONMENT>`) to apply the blueprint changes
1. Uncomment `custom_output_configuration.blueprints` line in the [DDE
   module][dde-module] to restore the silencing.

If you don't use the `check-infra-deploy-status.yml` workflow and/or are
expecting frequent changes to the needed blueprints, you could remove the
`ignore_chnages` block so that changes take effect via the regular deployment
process.

[dde-module]: /infra/modules/document-data-extraction/resources/main.tf

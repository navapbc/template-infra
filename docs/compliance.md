# Compliance

We use the [Checkov](https://www.checkov.io/) static analysis tool to check for compliance with infrastructure policies.

## Setup

To run this tool locally, first install Checkov by running the following command.

```bash
brew install checkov
```

## Check compliance

```bash
make infra-check-compliance
```

## Pre-Commit

If you use [pre-commit](https://www.checkov.io/4.Integrations/pre-commit.html), you can optionally add checkov to your own pre-commit hook by following the instructions [here](https://www.checkov.io/4.Integrations/pre-commit.html).

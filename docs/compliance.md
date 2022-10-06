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

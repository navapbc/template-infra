# Set up HTTPS

Follow these instructions for **each network** (you can have one or more in your project) in your project. If the network or an application does not need HTTPS, skip to the bottom of this document.

To prevent man-in-the-middle attacks, production systems should use HTTPS rather than HTTP.

The HTTPS set up process will:

* Issue an SSL/TLS certificate using Amazon Certificate Manager (ACM) for each domain that should support HTTPS
* Associate the certificate with the application's load balancer, so that the load balancer can serve HTTPS requests

## Prerequisites

* You have [set up custom domains](./set-up-network-custom-domains.md) and met all of those prerequisites.

This is because SSL/TLS certificates must be properly configured for the specific domain to support establishing secure connections.

## Instructions

### 1. Make sure you're authenticated into the AWS account you want to configure

This setup applies to the account you're authenticated into. To see which account that is, run:

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run:

```bash
aws iam list-account-aliases
```

### 2. Set desired certificates in domain configuration

**For each network** you want to configure, modify the network in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf) to set the `certificate_configs` key.

Set the `source` of the domain or subdomain to `issued`.

### 3. Update the network layer to issue the certificates

**For each network** you configured in the previous step, apply the changes by running the following command. Review the Terraform output carefully before typing "yes" to apply the changes. This will issue SSL/TLS certificates.

```bash
make infra-update-network NETWORK_NAME=<NETWORK_NAME>
```

Run the following command to check the status of a certificate (replace `<CERTIFICATE_ARN>` with the output from the previous command):

```bash
aws acm describe-certificate --certificate-arn <CERTIFICATE_ARN> --query Certificate.Status
```

### 4. Update `enable_https = true` in `app-config`

**For each application and environment** that should use HTTPS, perform the following.

Within the `app-config` directory (e.g. `infra/<APP_NAME>/app-config`), each environment has its own config file named after the environment. For example, if the application has three environments `dev`, `staging`, and `prod`, it should have corresponding `dev.tf`, `staging.tf`, and `prod.tf` files.

In each environment config file, set `enable_https` to `true`. This will attach the SSL/TLS certificate to the load balancer.

You should have already set `domain_name` as part of [setting up custom domain names](/docs/infra/set-up-network-custom-domains.md).

### 5. Attach certificate to load balancer

**For each application and environment** that should use HTTPS, apply the changes from the previous step by running the following command. Review the Terraform output carefully before typing "yes" to apply the changes.

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` must be the name of the application folder within the `infra` folder.

`ENVIRONMENT` must be the name of the environment to update.

## If a network does not need HTTPS

**⚠️ This is not advised** for any network containing a production environment.

For each network that does not need custom domains, in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf), set the network's `certificate_configs` to `{}` (empty hash).

## If an application does not need HTTPS

**⚠️ This is not advised** for an application deployed to a production environment.

For each application that does not need HTTPS, in the application's `app-config/<ENVIRONMENT>.tf` file (e.g. in `/infra/<APP_NAME>/app-config/<ENVIRONMENT>.tf`), set `enable_https` to `false`.
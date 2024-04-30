# Custom domains

Follow these instructions for **each network** (you can have one or more in your project) in your project. If the network or an application does not need custom domains, skip to the bottom of this document.

Production systems will want to set up custom domains to route internet traffic to their application services rather than using AWS-generated hostnames for the load balancers or the CDN. This document describes how to configure custom domains.

The custom domain setup process will:

1. Create an [Amazon Route 53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) to manage DNS records for a domain and subdomains
2. Create DNS A (address) records to route traffic from a custom domain to an application's load balancer

## Prerequisites

* You'll need to have registered custom domain(s) with a domain registrar (e.g. Namecheap, GoDaddy, Google Domains, etc.)
* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md)
* You'll need to have [configured all applications](./set-up-app-config.md)
* You'll need to have [set up the networks](./set-up-network.md) that you want to add the custom domain to
* You'll need to have [set up the application service](./set-up-app-service.md)

## Instructions

### 1. Make sure you're authenticated into the AWS account you want to configure

This set up takes effect in whatever account you're authenticated into. To see which account that is, run

```bash
aws sts get-caller-identity
```

To see a more human readable account alias instead of the account, run

```bash
aws iam list-account-aliases
```

### 2. Set hosted zone in domain configuration

The custom domain configuration is defined as a `domain_config` object in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf). A [hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) represents a domain and all of its subdomains.

For example, a hosted zone of `platform-test.navateam.com` includes `platform-test.navateam.com`, `cdn.platform-test.navateam.com`, `notifications.platform-test.navateam.com`, `foo.bar.platform-test.navateam.com`, etc.

**For each network** you want to use a custom domain, set the `hosted_zone` value in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf) to match the custom domain (or a subdomain of the custom domain) that you registered.

### 3. Update the network layer to create the hosted zones

**For each network** you that you added a custom domain to in the previous step, run the following command to create the hosted zone specified in the domain configuration:

```bash
make infra-update-network NETWORK_NAME=<NETWORK_NAME>
```

### 4. Delegate DNS requests to the newly created hosted zone

You most likely registered your domain outside of this project. Using whichever service you used to register the domain name (e.g. Namecheap, GoDaddy, Google Domains, etc.), add a DNS NS (nameserver) record. Set the "name" equal to the `hosted_zone` and set the value equal to the list of hosted zone name servers that was created in the previous step. You can see the list of servers by running

```bash
terraform -chdir=infra/networks output -json hosted_zone_name_servers
```

Your NS record might look something like this:

**Name**:

```text
platform-test.navateam.com
```

**Value**: (Note the periods after each of the server addresses)

```text
ns-1431.awsdns-50.org.
ns-1643.awsdns-13.co.uk.
ns-687.awsdns-21.net.
ns-80.awsdns-10.com.
```

Run the following command to verify that DNS requests are being served by the hosted zone nameservers using `nslookup`.

```bash
nslookup -type=NS <HOSTED_ZONE>
```

### 5. Create DNS A (address) records to route traffic from the custom domain to the application's load balancer

**For each application** in the network that should use the custom domain, perform the following.

Within the `app-config` directory (e.g. `infra/<APP_NAME>/app-config`), each environment has its own config file named after the environment. For example, if the application has three environments `dev`, `staging`, and `prod`, it should have corresponding `dev.tf`, `staging.tf`, and `prod.tf` files.

In each environment config file, define the `domain_name`.

The `domain_name` must be either the same as the `hosted_zone` or a subdomain of the `hosted_zone`. For example, if your hosted zone is `platform-test.navateam.com`, then `platform-test.navateam.com` and `cdn.platform-test.navateam.com` are both valid values for `domain_name`.

### 6. Update the application service

**For each application and each environment** in the network that should use the custom domain, apply the changes with the following command

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` needs to be the name of the application folder within the `infra` folder.

`ENVIRONMENT` needs to be the name of the environment.

## Externally managed DNS

--- @TODO create ticket to make this a local that is derived from hosted_zone

If DNS records are managed externally outside of the project, set `network_configs[*].domain_config.manage_dns = false` in [the networks section of the project-config module](/infra/project-config/networks.tf).

## If a network does not need custom domains

For each network that does not need custom domains, ensure the network's `domain_config` setting in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf). looks like this:

```json
domain_config = {
  manage_dns  = false
  hosted_zone = ""
  certificate_configs = {}
}
```

## If an application does not need custom domains

For each application that does not need custom domains, ensure that the application's `app-config/<ENVIRONMENT>.tf` file (e.g. in `/infra/<APP_NAME>/app-config/<ENVIRONMENT>.tf`) has `domain_name` set to `""` (empty string).

# Set up custom domains

Follow these instructions for **each network** (you can have one or more in your project) in your project. If the network or an application does not need custom domains, skip to the bottom of this document.

Production systems typically use custom domains to route internet traffic to their application services instead of AWS-generated hostnames for the load balancers or the CDN.

The custom domain set up process will:

* Create an [Amazon Route 53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) to manage DNS records for a domain and subdomains
* Create DNS A (address) records to route traffic from a custom domain to an application's load balancer

## Prerequisites

* You have registered custom domain(s) with a domain registrar (e.g. Namecheap, GoDaddy, Google Domains, etc.).
* You have [set up the AWS account(s)](./set-up-aws-accounts.md).
* You have [configured all application(s)](./set-up-app-config.md).
* You have [set up the networks](./set-up-network.md) that you want to add the custom domain to.
* You have [set up the application service](./set-up-app-service.md).

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

### 2. Set hosted zone in domain configuration

The custom domain configuration is defined as a `domain_config` object in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf). A [hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) represents a domain and all of its subdomains. For example, a hosted zone of `platform-test.navateam.com` includes `platform-test.navateam.com`, `cdn.platform-test.navateam.com`, `notifications.platform-test.navateam.com`, `foo.bar.platform-test.navateam.com`, etc.

**For each network** you want to use a custom domain, in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf):

1. Set the `hosted_zone` to match the custom domain (or a subdomain of the custom domain) that you registered.
2. Set `manage_dns` to `true`.

### 3. Update the network layer to create the hosted zones

**For each network** you that you added a custom domain to in the previous step, run the following command to create the hosted zone specified in the domain configuration:

```bash
make infra-update-network NETWORK_NAME=<NETWORK_NAME>
```

### 4. Delegate DNS requests to the newly created hosted zone

You most likely registered your domain outside of this project. Using whichever service you used to register the domain name (e.g. Namecheap, GoDaddy, Google Domains, etc.), add a DNS NS (nameserver) record. Set the "name" equal to the `hosted_zone` and set the value equal to the list of hosted zone name servers that was created in the previous step.

Output a list of servers by running:

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

Verify that DNS requests are being served by the hosted zone nameservers by running the following command:

```bash
nslookup -type=NS <HOSTED_ZONE>
```

### 5. Create DNS A (address) records to route traffic from the custom domain to the application's load balancer

**For each application** in the network that should use the custom domain, perform the following.

Within the `app-config` directory (e.g. `infra/<APP_NAME>/app-config`), each environment has its own config file named after the environment. For example, if the application has three environments `dev`, `staging`, and `prod`, it should have corresponding `dev.tf`, `staging.tf`, and `prod.tf` files.

In each environment config file, define the `domain_name`.

The `domain_name` must be either the same as the `hosted_zone` or a subdomain of the `hosted_zone`. For example, if your hosted zone is `platform-test.navateam.com`, then `platform-test.navateam.com` and `cdn.platform-test.navateam.com` are both valid values for `domain_name`.

### 6. Update the application service

**For each application and each environment** in the network that should use the custom domain, apply the changes by running the following command. Review the Terraform output carefully before typing "yes" to apply the changes.

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

`APP_NAME` must be the name of the application folder within the `infra` folder.

`ENVIRONMENT` must be the name of the environment to update.

## If a network does not need custom domains

For each network that does not need custom domains, set the network's `domain_config` object in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf) to the following:

```hcl
domain_config = {
  manage_dns  = false
  hosted_zone = ""
  certificate_configs = {}
}
```

## If an application does not need custom domains

For each application that does not need custom domains, in the application's `app-config/<ENVIRONMENT>.tf` file (e.g. `/infra/<APP_NAME>/app-config/<ENVIRONMENT>.tf`), set `domain_name` to `""` (empty string).

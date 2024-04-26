# Custom domains

Production systems will want to set up custom domains to route internet traffic to their application services rather than using AWS-generated hostnames for the load balancers or the CDN. This document describes how to configure custom domains.

**For each network**, the custom domain setup process will:

1. Create an [Amazon Route 53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) to manage DNS records for a domain and subdomains
2. Create a DNS A (address) records to route traffic from a custom domain to an application's load balancer

## Prerequisites

* You'll need to have registered custom domain(s) with a domain registrar (e.g. Namecheap, GoDaddy, Google Domains, etc.).
* You'll need to have [set up the AWS account(s)](./set-up-aws-accounts.md).
* You'll need to have [configured all applications](./set-up-app-config.md).
* You'll need to have [set up the networks](./set-up-network.md) that you want to add the custom domain to.

## Instructions

Follow these instructions for **each network** you want to setup custom domains for.

### 1. Set hosted zone in domain configuration

The custom domain configuration is defined as a `domain_config` object in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf). A [hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) represents a domain and all of its subdomains.

For example, a hosted zone of `platform-test.navateam.com` includes `platform-test.navateam.com`, `cdn.platform-test.navateam.com`, `notifications.platform-test.navateam.com`, `foo.bar.platform-test.navateam.com`, etc.

**For each network** you want to use a custom domain, modify the `hosted_zone` value in [`/infra/project-config/networks.tf`](/infra/project-config/networks.tf) to match the custom domain (or a subdomain of the custom domain) that you registered. Each `hosted_zone` value must be different.

### 2. Enable custom domains

In the [network module](/infra/networks/main.tf), enable custom domains by uncommenting the `module "domain"` section.

### 3. Update the network layer to create the hosted zones

**For each network** you that you added a custom domain to in Step 1, run the following command to create the hosted zone specified in the domain configuration:

```bash
make infra-update-network NETWORK_NAME=<NETWORK_NAME>
```

### 3. Delegate DNS requests to the newly created hosted zone

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

### 4. Configure custom domain for your application

Define the `domain_name` for each of the application environments in the `app-config` module. The `domain_name` must be either the same as the `hosted_zone` or a subdomain of the `hosted_zone`. For example, if your hosted zone is `platform-test.navateam.com`, then `platform-test.navateam.com` and `cdn.platform-test.navateam.com` are both valid values for `domain_name`.

### 5. Create DNS A (address) records to route traffic from the custom domain to your application's load balancer

If created after....

Run the following command to create the A record that routes traffic from the custom domain to the application's load balancer.

```bash
make infra-update-app-service APP_NAME=<APP_NAME> ENVIRONMENT=<ENVIRONMENT>
```

### 6. Repeat for each application

If you have multiple applications in the same network, repeat steps 4 and 5 for each application.

## Externally managed DNS

If you plan to manage DNS records outside of the project, then set `network_configs[*].domain_config.manage_dns = false` in [the networks section of the project-config module](/infra/project-config/networks.tf).

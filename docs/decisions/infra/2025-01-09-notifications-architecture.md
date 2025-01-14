# Notifications Architecture

- Status: accepted
- Deciders: @lorenyu, @coilysiren
- Date: 2025-01-09

## Context and Problem Statement

Many projects need to set up email notifications for both transactional and marketing purposes. This process is currently complex and iterative, requiring multiple steps, including:

- Spinning up the relevant resources in the cloud provider.
- Configuring email security settings such as DKIM and DMARC.
- Integrating with the application server.

The goal is to design a notifications infrastructure that simplifies setup for project teams, is straightforward to understand, and can be easily extended as needed.

## Decision Drivers

- Avoid circular dependencies.
- Avoid revisiting a layer (e.g., network layer, service layer) more than once during application environment setup.
- Keep the architecture simple to understand and customize.
- Minimize the number of steps required to set up an environment.
- Ensure the solution is testable at each step.

## Considered Options

### Consideration 1: Which domain should be used for the sender's email address?

1. **Option 1**: Use the domain of the app.
   - **Pros**:
     - Simplifies the developer experience by allowing reuse of the custom app domain already being set up.
   - **Cons**:
     - Requires [BYODKIM (Bring Your Own DKIM)](https://docs.aws.amazon.com/ses/latest/dg/send-email-authentication-dkim-bring-your-own.html), which involves generating public/private key pairs out of band, adding complexity to maintain key pairs securely since the Terraform [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) resource is not recommended for production.

2. **Option 2 (Chosen)**: Use the domain of the environment (e.g., hosted zone).
   - **Pros**:
     - Leverages Amazon’s Easy DKIM, simplifying setup by automatically managing public/private keys.
   - **Cons**:
     - In multi-app repositories, applications that share environments (dev, staging, prod) and hosted zones cannot create their own domain email identity since it would create a naming conflict. Therefore, enabling notifications for a second app requires custom work to allow sharing of the notification resources from the first app.

### Consideration 2: Where should notifications resources be defined?

1. **Option 1**: Create resources as a new app/microservice shared by other apps.
   - **Pros**:
     - Allows for a single notifications sandbox environment to support multiple applications across multiple non-production environments
     - Avoids duplication of resources across multiple apps
     - Most modular, allowing for more flexible scaling and resource management.
   - **Cons**:
     - Adds operational complexity by requiring notifications to be separately deployed
     - Requires notifications to be designed to support multiple tenants (multiple applications across multiple environments) which adds significant complexity within the notifications service.

2. **Option 2**: Create resources in a new layer (e.g., build repository layer) shared across apps.
   - **Cons**:
     - Adds conceptual complexity to the infrastructure by creating a new separate layer
     - Adds operational complexity by requiring the notifications layer to be separately deployed

3. **Option 3**: Create resources in the service layer for each app needing notifications.
   - **Pros**:
     - Simplest to understand as it mirrors the structure of the rest of the infrastructure
   - **Cons**:
     - Only feasible if domains are not shared across multiple applications i.e. we use the domain of the app for sender email notifications, which was not the chosen option due to other factors.

4. **Option 4 (Chosen)**: Create resources in the service layer of one app and require custom work for others to access the notifications service in the app that contains that service.
   - **Pros**:
     - As simple as Option 3 for projects where only one app needs to send notifications, which is the common case
   - **Cons**:
     - May require custom work in cases where more than one app needs to send notifications

### Consideration 3: Which layer should contain DKIM and DMARC DNS Records?

1. **Option 1**: Create records in the network layer.
   - **Pros**:
     - DNS records conceptually fits with the network layer

2. **Option 2 (Chosen)**: Create records in the service layer.
   - **Pros**:
     - Mirrors design for A records for custom domains which are also in the service layer

## Decision Outcome

**Summary of chosen options**:

- Use the domain of the environment (e.g. hosted zone) for the sender's email address.
- Create resources in the service layer of one app and require custom work for other applications in the same repo to access the notifications service.
- Create DKIM and DMARC DNS Records in the service layer.

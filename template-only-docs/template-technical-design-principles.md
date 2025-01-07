# Template technical design principles

This document outlines the technical design principles that the template-infra project follows. These principles guide the development of the infrastructure template.

## Design for simplicity

### Design for the common case

- Optimize for the common case
- Avoid adding unnecessary flexibility that increases complexity
- Ensure that uncommon cases can be addressed through explicit customization

### Foster developer understanding and ownership

- Ensure the infrastructure is transparent and comprehensible to project teams.
- Encourage developers to understand the inner workings of the infrastructure so they are equipped to extend or customize it as needed.

### Maintain a level of complexity comparable to what project teams would manage if building the functionality themselves

- Avoid adding complexity to the project that arises from the fact that the code came from a template
- Avoid adding complexity to the project that arises from the need to support multiple use cases

### Establish strong conventions and sensible defaults

- Use conventions to eliminate unnecessary decision-making and prevent bikeshedding. For example, require a `Makefile` with a `release-build` target in all applications rather than allow project teams to decide what command to use for building the container.
- Adopt sensible defaults to minimize configuration overhead. For example, hardcode values (e.g., healthcheck timeout and interval) where flexibility is unnecessary.

### Minimize the surface area of interfaces

- Design interfaces with the minimum number of inputs required to meet the needs of most teams. For example, minimize the number of variables to Terraform modules and the number of inputs to GitHub Actions workflows.
- Provide default values to inputs when possible.

## Prefer configuration files over template variables

The infra template supports configuration through the following mechanisms:

- Configurations in project-config and app-config Terraform modules
- Template variables stored in answers files in the `.template-infra` directory

In general, prefer configuration behavior through the static project-config and app-config modules.

Use template variables only when defining configuration for things that cannot access Terraform state. Examples include:

- Defining the name of an application when adding an application to the project. This cannot be hardcoded (e.g. to `app`) for multi-application projects.
- Defining the local port to use when running the application locally during local development. This is used by docker-compose.yml and cannot be hardcoded since a multi-application project cannot run multiple applications on the same port.
- Toggling GitHub Actions workflows on and off based on whether the project team has finished setting up their application's dev environment. While GitHub Actions workflows can access project-config and app-config within the workflow, project-config and app-config cannot be used to disable a workflow trigger entirely. It would be possible to add an extra calling workflow that can first check the project-config and app-config and then call the actual workflow, but this would add unnecessary complexity and violate the principle of maintaining a level of complexity comparable to what project teams would manage if building the functionality themselves.

Examples of template variables include `app_name`, which is used to name the application folder, and `app_local_port`, which defines the port to be used when running the application locally during local development.

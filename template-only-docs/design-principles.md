# Design Principles

These are the principles that guide the design of the infrastructure template.

## Manage dependencies between root modules through config modules and data resources

Rather than using outputs and variables

Reasons:

* It makes the dependency explicit from the module, rather than implicit. For example, we can easily see all the places that rely on `module.project_config.X`. When using the outputs and variables approach, we save the outputs of one root module into a tfvars file for another root module. But if we change or remove the output of the upstream root module, it won't be clear what downstream root modules need to be reconfigured and changed.
* This also minimizes the amount of logic that exists in the intermediate shell scripts that configure the various root module layers.

## 


# Destroy infrastructure

Whether you just want to destroy a single application or tear everything down,
you'll need to undeploy all the infrastructure in reverse order that things were
created (see /infra/README.md#Getting-started). In particular, the account root
module(s) need to be destroyed last if you are going that far.

## Utilities

In the upstream [template-infra/template-only/bin/
directory](https://github.com/navapbc/template-infra/tree/main/template-only-bin)
there are `destroy-*` scripts for each layer that automate most of the
trickiness of the process.

> [!WARNING]
> These scripts auto-approve the terraform changes, you will not have a chance
> to review!

See the next section for some of what makes it "tricky". If you'd rather have
more control over the destruction, you'll want to review and probably copy-paste
commands out of the scripts regardless.

## Considerations

### Delete protection

A variety of resources have delete protection enabled, so you can't just run a
`terraform destroy`/`terrafom apply -destroy` on them.

### Remote state

A consideration applicable only to the account root module really.

TODO

### Multiple instances

The project may have many application environments and multiple networks, each
of which will need to be torn down separately. You'll likely want to automate
the process for repeatability.

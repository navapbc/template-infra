# Release Management

## Building a release

To build a release, run

```bash
make release-build APP_NAME=<APP_NAME>
```

This calls the `release-build` target in `<APP_NAME>/Makefile` with some
parameters to build an image. The `<APP_NAME>/Dockerfile` should have a build
stage called `release` to act as the build target. (See [Name your build
stages](https://docs.docker.com/build/building/multi-stage/#name-your-build-stages))

## Publishing a release

TODO

## Deploying a release

TODO

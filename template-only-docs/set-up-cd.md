# Set up CD

Once you have set up your application environments (at least `dev`), you can
enable continuous deployment by running:

```sh
nava-platform infra update --data app_has_dev_env_setup=true .
```

And update the `role-to-assume` with the GitHub actions ARN.

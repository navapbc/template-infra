# Set up CD

Once you have set up your application environments (at least `dev`), you can
enable continuous deployment by running:

```sh
nava-platform update --data is_dev_env_setup=true
```

TODO still needed?
1. Update the `role-to-assume` with the GitHub actions ARN.

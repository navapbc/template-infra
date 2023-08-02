# Set up CD

Once you have set up your application environments, you can enable continuous deployment in [cd.yml](../.github/workflows/cd.yml) by searching for `!!` and following the instructions to:

1. Update the `role-to-assume` with the GitHub actions ARN.
2. Uncomment the `on: push: ["main]` workflow trigger. This will trigger the deployment workflow on every merge to `main`.

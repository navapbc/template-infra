# Set up CD

Once you have set up your application(s), you can enable continuous deployment. Each application should have a CD Github Actions workflow (e.g. `/.github/workflows/cd-<APP_NAME>`).

In each `/.github/workflows/cd-<APP_NAME>`, search for `!!` and following the instructions to:

1. Update the `role-to-assume` with the GitHub actions ARN.
2. Uncomment the `on: push: ["main]` workflow trigger. This will trigger the deployment workflow on every merge to `main`.

# Template release management

1. Every week look at the commits that have been merged to `main` and decide if we want to create a new infra template release
2. Choose a version number based on the changes that have been merged.
   1. If there are changes that are not backwards compatible, usually flagged with a ⚠️ icon, increase the major version number (or minor version number while we are still on 0.*.* releases).
   2. If there are significant new features, increase the minor version number.
   3. If there are only bug fixes, tech debt, DevEx improvements, or other minor changes, increase the patch version number.
3. Generate release notes
4. Adjust release notes as needed:
   1. Add a summary at the top of the release notes highlighting the most important changes, and call out any breaking changes.
   2. Add a table of the infrastructure layers that have been updated. This table should inform project teams which layers they need to run `make infra-update-*` for.
   3. Organize the commit messages into sections, adding a section for each layer that has been updated.
   4. Reword commit messages to be more user-friendly to users of the Platform who have less context of the Platform internals

# Contributing

To ensure the long-term stability and quality of this project, we are moving to a closed-contribution model effective August 2025. This change allows our core team to focus on a centralized development roadmap and rigorous quality assurance, which is essential for a component with such extensive usage.

All of our development will remain public for transparency. We thank the community for its support and valuable contributions.

Here is an adjusted `CONTRIBUTING.md` file designed for both external users and Snyk engineers. It clearly separates the public-facing policy from the internal-facing development and release instructions.

-----

## **Internal Contributions (for Snyk Engineers)**

### **The Release Process**

Our project uses an automated release workflow to ensure new versions are consistent and error-free. The release is [triggered automatically](./.github/workflows/release.yaml) whenever a pull request is merged into the `main` branch.

The process uses [semantic versioning](https://semver.org/) to automatically determine the next version number based on the [commit messages](https://www.conventionalcommits.org/en/v1.0.0/) in the merged pull request.

### **How to Trigger a Major Version Change**

A major version change (e.g., `v1.x.x` to `v2.0.0`) is reserved for significant, **breaking changes** to the project.

To trigger a major version bump, your pull request **must** contain at least one commit message that includes the `BREAKING CHANGE:` footer.

**Example Commit Message:**

```text
feat: Add a new API endpoint for user authentication

This commit introduces a new /api/v1/auth endpoint.

BREAKING CHANGE: The old authentication method is no longer supported. Please use the new endpoint.
```

The presence of this specific footer signals to the automated release workflow that a new major version is required. Without it, the workflow will only increment the patch or minor version.
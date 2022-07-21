# Snyk Infrastructure as Code Action

A [GitHub Action](https://github.com/features/actions) for using [Snyk](https://snyk.io) to check for
issues in your Infrastructure as Code files.

You can use the Action as follows:

```yaml
name: Example workflow for Snyk Infrastructure as Code
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - name: Run Snyk to check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          file: your/kubernetes-manifest.yaml
```

The Snyk Infrastructure as Code Action has properties which are passed to the underlying image. These are
passed to the action using `with`.

| Property | Default | Description                                                      |
|----------|---------|------------------------------------------------------------------|
| args     |         | Override the default arguments to the Snyk image                 |
| command  | test    | Specify which command to run, currently only `test` is supported |
| file     |         | The file to check for issues.                                    |
| json     | false   | In addition to the stdout, save the results as snyk.json         |
| sarif    | true    | In addition to the stdout, save the results as snyk.sarif        |

For example, you can choose to only report on high severity vulnerabilities.

```yaml
name: Example workflow for Snyk Infrastructure as Code
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - name: Run Snyk to check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          file: your/kubernetes-manifest.yaml
          args: --severity-threshold=high
```

The Infrastructure as Code Action also supports integrating with GitHub Code Scanning and can show issues in the GitHub Security tab. When run, a `snyk.sarif` file will be generated which can be uploaded to GitHub Code Scanning.

```yaml
name: Snyk Infrastructure as Code
on: push
jobs:
  snyk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Snyk to check configuration files for security issues
        # Snyk can be used to break the build when it detects security issues.
        # In this case we want to upload the issues to GitHub Code Scanning
        continue-on-error: true
        uses: snyk/actions/iac@master
        env:
          # In order to use the Snyk Action you will need to have a Snyk API token.
          # More details in https://github.com/snyk/actions#getting-your-snyk-token
          # or you can signup for free at https://snyk.io/login
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          # Add the path to the configuration file that you would like to test.
          # For example `deployment.yaml` for a Kubernetes deployment manifest
          # or `main.tf` for a Terraform configuration file
          file: your-file-to-test.yaml
      - name: Upload result to GitHub Code Scanning
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: snyk.sarif
```

### Specifying Multiple Files

If you want to run IaC tests against multiple files, the [Build Matrix](https://docs.github.com/en/actions/using-jobs/using-a-build-matrix-for-your-jobs) feature can be used.

```yaml
name: Example workflow for Snyk Infrastructure as Code with multiple files
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        files:
          - main.tf
          - outputs.tf
          - variables.tf
    steps:
      - name: Run Snyk to check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          file: ${{ matrix.files }}
```

The Actions example above refers to a `files` list that must contain at least _one_ supported file.

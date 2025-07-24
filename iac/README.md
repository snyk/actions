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
      - uses: actions/checkout@master
      - name: Run Snyk to check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

In order to use the Snyk Infrastructure as Code Test Action, you will need to have a Snyk API token.
More details in [Getting Your Snyk Token](https://github.com/snyk/actions#getting-your-snyk-token), or you can [sign up for free](https://snyk.io/login).

The Snyk Infrastructure as Code Action has properties which are passed to the underlying image. These are
passed to the action using `with`:

| Property  | Default  | Description                                                       |
| --------- | -------- | ----------------------------------------------------------------- |
| `args`    |          | Override the default arguments to the Snyk image.                 |
| `command` | `"test"` | Specify which command to run, currently only `test` is supported. |
| `file`    |          | The paths in which to scan files with issues.                     |
| `json`    | `false`  | In addition to the stdout, save the results as snyk.json          |
| `sarif`   | `true`   | In addition to the stdout, save the results as snyk.sarif         |

## Examples

### Specifying paths

You can specify the paths to the configuration files and directories to target during the test.  
When no path is specified, the whole repository is scanned by default:

```yaml
name: Example workflow for Snyk Infrastructure as Code
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Run Snyk to check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          file: your/kubernetes-manifest.yaml your/terraform/directory
```

### Specifying severity threshold

You can also choose to only report on high severity vulnerabilities:

```yaml
name: Example workflow for Snyk Infrastructure as Code
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Run Snyk to check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          file: your/kubernetes-manifest.yaml
          args: --severity-threshold=high
```

### Sharing test results

You can [share your test results](https://docs.snyk.io/products/snyk-infrastructure-as-code/share-cli-results-with-the-snyk-web-ui) to the Snyk platform:

```yaml
name: Example workflow for Snyk Infrastructure as Code
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Run Snyk to check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --report
```

### Specifying scan mode for Terraform Plan

You can also choose the [scan mode](https://docs.snyk.io/products/snyk-infrastructure-as-code/snyk-cli-for-infrastructure-as-code/test-your-terraform-files-with-the-cli-tool#terraform-plan), when scanning Terraform Plan files:

```yaml
name: Example workflow for Snyk Infrastructure as Code
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Run Snyk to check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --scan=resource-changes
```

### Integrating with GitHub Code Scanning

The Infrastructure as Code Action also supports integrating with GitHub Code Scanning and can show issues in the GitHub Security tab. When run, a `snyk.sarif` file will be generated which can be uploaded to GitHub Code Scanning:

```yaml
name: Snyk Infrastructure as Code
on: push
jobs:
  snyk:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
    steps:
      - uses: actions/checkout@master
      - name: Run Snyk to check configuration files for security issues
        # Snyk can be used to break the build when it detects security issues.
        # In this case we want to upload the issues to GitHub Code Scanning
        continue-on-error: true
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      - name: Upload result to GitHub Code Scanning
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: snyk.sarif
```

## Related Documentation

For more information on how to use the `snyk iac test` command, see the following:

- [Snyk CLI for Infastructure as Code](https://docs.snyk.io/products/snyk-infrastructure-as-code/snyk-cli-for-infrastructure-as-code)
- [Snyk Infrastructure as Code Test Command](https://docs.snyk.io/snyk-cli/commands/iac-test)

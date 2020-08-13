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

The Snyk Docker Action has properties which are passed to the underlying image. These are
passed to the action using `with`.

| Property | Default | Description |
| --- | --- | --- |
| args |   | Override the default arguments to the Snyk image |
| command | test | Specify which command to run, currently only `test` is supported |
| file |    | The file to check for issues. Currently only single files are supported |

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

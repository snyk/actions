# Snyk Node Action

A [GitHub Action](https://github.com/features/actions) for using [Snyk](https://snyk.io) to check for
vulnerabilities in your Node projects.

You can use the Action as follows:

```yaml
name: Example workflow for Node usng Snyk 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: garethr/snyk-actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

The Snyk Node Action has properties which are passed to the underlying image. These are
passed to the action using `with`.

| Property | Default | Description |
| --- | --- | --- |
| args |   | Override the default arguments to the Snyk image |

For example, you can choose to only report on high severity vulnerabilities.

```yaml
name: Example workflow for Node usng Snyk 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: garethr/snyk-actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: snyk test --severity-threshold=high
```

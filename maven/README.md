# Snyk Maven Action

A [GitHub Action](https://github.com/features/actions) for using [Snyk](https://snyk.co/SnykGH) to check for
vulnerabilities in your Maven projects.

You can use the Action as follows:

```yaml
name: Example workflow for Maven using Snyk 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/maven@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

The Snyk Maven Action has properties which are passed to the underlying image. These are
passed to the action using `with`.

| Property | Default | Description |
| --- | --- | --- |
| args |   | Override the default arguments to the Snyk image |
| command | test | Specify which command to run, for instance test or monitor |
| json | false | In addition to the stdout, save the results as snyk.json |

For example, you can choose to only report on high severity vulnerabilities.

```yaml
name: Example workflow for Maven using Snyk 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/maven@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

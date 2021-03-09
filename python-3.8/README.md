# Snyk Python (3.8)  Action

A [GitHub Action](https://github.com/features/actions) for using [Snyk](https://snyk.co/SnykGH) to check for
vulnerabilities in your Python-3.8 projects.

You can use the Action as follows:

```yaml
name: Example workflow for Python using Snyk 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/python-3.8@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

The Snyk Python Action has properties which are passed to the underlying image. These are
passed to the action using `with`.

| Property | Default | Description |
| --- | --- | --- |
| args |   | Override the default arguments to the Snyk image |
| command | test | Specify which command to run, for instance test or monitor |
| json | false | In addition to the stdout, save the results as snyk.json |

For example, you can choose to only report on high severity vulnerabilities.

```yaml
name: Example workflow for Python using Snyk 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/python-3.8@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

# Snyk Setup Action

A [GitHub Action](https://github.com/features/actions) for installing [Snyk](https://snyk.co/SnykGH) to check for
vulnerabilities.

You can use the Action as follows:

```yaml
name: Snyk example 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: snyk/actions/setup@master
    - uses: actions/setup-go@v1
      with:
        go-version: "1.13"
    - name: Snyk monitor 
      run: snyk test
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

When using the Setup Action you are responsible for setting up the development environment required to run Snyk.
In this case this is a Go project so `actions/setup-go` was used, but this would be specific to your project. The [language and frameworks guides](https://docs.github.com/en/actions/language-and-framework-guides) are a good starting point.

The Snyk Setup Action has properties which are passed to the underlying image. These are
passed to the action using `with`.

| Property | Default | Description |
| --- | --- | --- |
| snyk-version | latest | Install a specific version of Snyk |

The Action also has outputs:

| Property | Default | Description |
| --- | --- | --- |
| version |   | The full version of the Snyk CLI installed |

For example, you can choose to install a specific version of Snyk. The installed version can be
grabbed from the output:

```yaml
name: Snyk example
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: snyk/actions/setup@master
      id: snyk
      with:
        snyk-version: v1.391.0
    - uses: actions/setup-go@v1
      with:
        go-version: "1.13"
    - name: Snyk version
      run: echo "${{ steps.snyk.outputs.version }}"
    - name: Snyk monitor 
      run: snyk monitor
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

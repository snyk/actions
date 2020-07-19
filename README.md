# Snyk GitHub Actions

![](https://github.com/snyk/actions/workflows/Generate%20Snyk%20GitHub%20Actions/badge.svg)

A set of [GitHub Action](https://github.com/features/actions) for using [Snyk](https://snyk.io) to check for
vulnerabilities in your GitHub projects. A different action is required depending on which language or build tool
you are using. We currently support:

* [CocoaPods](cocoapods)
* [DotNet](dotnet)
* [Golang](golang)
* [Gradle](gradle)
* [Gradle-jdk11](gradle-jdk11)
* [Gradle-jdk12](gradle-jdk12)
* [Maven](maven)
* [Maven-3-jdk-11](maven-3-jdk-11)
* [Node](node)
* [PHP](php)
* [Python](python)
* [Ruby](ruby)
* [Scala](scala)
* [Docker](docker)

Here's an example of using one of the Actions, in this case to test a Node.js project:

```yaml
name: Example workflow using Snyk
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```


If you want to send data to Snyk, and be alerted when new vulnerabilities are discovered, you can run Snyk monitor like so:


```yaml
name: Example workflow using Snyk
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        command: monitor
```


See the individual Actions linked above for per-language instructions.

Note: GitHub Actions will not pass on secrets set in the repository to forks being used in pull requests, and so the Snyk actions that require the token will fail to run.

## Getting your Snyk token

The Actions example above refer to a Snyk API token:

```
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

Every Snyk account has this token, and you can find it in one of two ways:
1. If you're using the [Snyk CLI](https://support.snyk.io/hc/en-us/articles/360003812458-Getting-started-with-the-CLI) you can retrieve it by running `snyk config get api`
2. In the UI, go to your account's general settings page (https://app.snyk.io/account) and retrieve the API token, as shown in the following [Revoking and regenerating Snyk API tokens](https://support.snyk.io/hc/en-us/articles/360004008278-Revoking-and-regenerating-Snyk-API-tokens).


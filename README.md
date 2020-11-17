# Snyk GitHub Actions

![](https://github.com/snyk/actions/workflows/Generate%20Snyk%20GitHub%20Actions/badge.svg)

A set of [GitHub Action](https://github.com/features/actions) for using [Snyk](https://snyk.co/SnykGH) to check for
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
* [Infrastructure as Code](iac)
* [Setup](setup)

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

Note that GitHub Actions will not pass on secrets set in the repository to forks being used in pull requests, and so the Snyk actions that require the token will fail to run.


### Bring your own development environment

The per-language Actions automatically install all the required development tools for Snyk to determine the correct dependencies and hence vulnerabilities from different language environments. If you have a workflow where you already have those installed then you can instead use the `snyk/actions/setup` Action to just install Snyk

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

The example here uses `actions/setup-go` would you would need to select the right actions to install the relevant development requirements for your project. If you are already using the same pipeline to build and test your application you're likely already doing so.


### Getting your Snyk token	

The Actions example above refer to a Snyk API token:

```yaml	
env:
  SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}	
```	

Every Snyk account has this token, and you can find it in one of two ways:	
1. If you're using the [Snyk CLI](https://support.snyk.io/hc/en-us/articles/360003812458-Getting-started-with-the-CLI) you can retrieve it by running `snyk config get api`.	
2. In the UI, go to your Snyk account's [settings page](https://app.snyk.io/account) and retrieve the API token, as shown in the following [Revoking and regenerating Snyk API tokens](https://support.snyk.io/hc/en-us/articles/360004008278-Revoking-and-regenerating-Snyk-API-tokens).


### GitHub Code Scanning support

Both the [Docker](docker) and [Infrastructure as Code](iac) Actions support integration with GitHub Code Scanning to show vulnerability information in the GitHub Security tab. You can see full details on the individual action READMEs. But here's an example using the Docker Action.

The Docker Action also supports integrating with GitHub Code Scanning and can show issues in the GitHub Security tab. As long as you reference a Dockerfile with `--file=Dockerfile` then a `snyk.sarif` file will be generated which can be uploaded to GitHub Code Scanning.

![GitHub Code Scanning and Snyk](docker/codescanning.png)

```yaml
name: Snyk Container
on: push
jobs:
  snyk:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build a Docker image
      run: docker build -t your/image-to-test .
    - name: Run Snyk to check Docker image for vulnerabilities
      # Snyk can be used to break the build when it detects vulnerabilities.
      # In this case we want to upload the issues to GitHub Code Scanning
      continue-on-error: true
      uses: snyk/actions/docker@master
      env:
        # In order to use the Snyk Action you will need to have a Snyk API token.
        # More details in https://github.com/snyk/actions#getting-your-snyk-token
        # or you can signup for free at https://snyk.io/login
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        image: your/image-to-test
        args: --file=Dockerfile
    - name: Upload result to GitHub Code Scanning
      uses: github/codeql-action/upload-sarif@v1
      with:
      sarif_file: snyk.sarif
```


### Continuing on error

The above examples will fail the workflow when issues are found. If you want to ensure the Action continues, even if Snyk finds vulnerabilities, then [continue-on-error](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error) can be used..

```yaml
name: Example workflow using Snyk with continue on error
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      continue-on-error: true
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

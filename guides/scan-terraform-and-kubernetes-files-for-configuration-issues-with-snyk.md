# Scan Terraform, Helm, and Kubernetes files for issues with Snyk IaC

You can use [Snyk Infrastructure as Code](https://snyk.co/InfraCode) to scan for security issues in Kubernetes and Terraform files, as part of your continuous integration \(CI\) workflow.

{% hint style="info" %}
GitHub Actions is available with GitHub Free, GitHub Pro, GitHub Free for organizations, GitHub Team, GitHub Enterprise Cloud, GitHub Enterprise Server, and GitHub One. GitHub Actions is not available for private repositories owned by accounts using legacy per-repository plans. For more information, see "[GitHub's products](https://docs.github.com/articles/github-s-products)."
{% endhint %}

## In this article

* Introduction
* Prerequisites
* Scanning files with Snyk IaC
* Adjusting severity thresholds for Snyk IaC
* Uploading IaC scan results to GitHub Security Code Scanning

## Introduction

This guide shows you how to create a workflow that scans Kubernetes and/or Terraform files for issues with [Snyk Infrastructure as Code \(IaC\)](https://snyk.co/InfraCode). It also covers setting severity thresholds for the IaC check, and uploading results to GitHub Security.

## Prerequisites

Create a GitHub Actions secret named `SNYK_TOKEN` to store the value for your Snyk Token. You can retrieve it from your [Snyk account settings](https://snyk.co/SnykSignUpGitHubGuide) or with the [Snyk CLI](https://snyk.co/SnykCLI):

```text
snyk config get api
```

For more information on creating secrets for GitHub Actions, see "[Encrypted secrets](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository)."

This guide assumes you have Terraform or Kubernetes manifests stored in a GitHub repository. Supported file extensions are `.tf` and `.yaml` . We recommend that you have a basic understanding of workflow configuration options and how to create a workflow file. For more information, see "[Learn GitHub Actions](https://docs.github.com/en/actions/learn-github-actions)."

## Scanning files with Snyk IaC

Each time you update your deployment YAML or Terraform files, it's a good idea to check them for security issues and misconfiguration risks. The example workflow below runs when a `push` event is triggered for the provided file `paths`. For more information on the `push` event, see "[Events that trigger workflows](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#push)".

In the example workflow below, we use the `Snyk IaC` action to scan a YAML file in a GitHub Repo. 

The `Snyk IaC` Action has properties that are passed to the underlying image using `with`:

* `args` : override the default arguments to the Snyk IaC image
* `command`: defaults to `test`, specify which command to run
* `file` : the file, or files, to check for issues.
* `json` : defaults to `false`, save the results as `snyk.json`
* `sarif`: default to true, save the results as `snyk.sarif`

```text
name: Example workflow for Snyk Infrastructure as Code
on:
  push:
    paths:
    - 'your/kubernetes-manifest.yaml'
jobs:
  iac-security:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          file: your/kubernetes-manifest.yaml
```

The above workflow checks out the GitHub repository, and uses the Snyk `IaC`  Action to scan the YAML file for issues. Snyk fails the check if any issues are found.

## Adjusting severity thresholds for Snyk IaC

You can adjust the severity level of the issues Snyk uses to determine wether to pass the check. For example, you can choose to fail only when medium severity issues are found . This is accomplished by with the `--severity-threshold` property. Accepted values are `high`, `medium`, and `low`.

```text
name: Example workflow for Snyk Infrastructure as Code
on:
  push:
    paths:
    - 'your/kubernetes-manifest.yaml'
jobs:
  iac-security:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Check Kubernetes manifest file for issues
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          file: your/kubernetes-manifest.yaml
          args: --severity-threshold=medium
```

The above workflow checks out the code, and uses the Snyk IaC action to scan the Kubernetes YAML file for issues. If High Severity issues are present, it will fail the check.

## Uploading IaC scan results to GitHub Security Code Scanning

The Snyk IaC Action also supports integrating with GitHub Security. When run, a `snyk.sarif` file will be generated which can be uploaded to GitHub Security to show issues in the repo's Security tab..

By default, Snyk IaC breaks the workflow when issues are present. You can continue the workflow to always upload results to GitHub Security by setting `continue-on-error`to true.

```text
name: Example workflow for Snyk Infrastructure as Code
on:
  push:
    paths:
    - 'your/kubernetes-manifest.yaml'
jobs:
  iac-security:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Check Kubernetes manifest file for issues
        continue-on-error: true
        uses: snyk/actions/iac@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          file: your/kubernetes-manifest.yaml
          args: --severity-threshold=high
      - name: Upload result to GitHub Code Scanning
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: snyk.sarif
```

The above workflow checks out the code, uses the Snyk Infrastructure as Code action to scan the Kubernetes YAML file for high severity issues, then uploads the results to GitHub Security Code Scanning.

## Additional Resources

* Snyk Docs: [Test your Kubernetes files with our CLI tool](https://snyk.co/TestK8sSnykCLI)
* Lab: [Securing a Toolchain with Snyk and GitHub](https://snyk.co/SecureToolChain)


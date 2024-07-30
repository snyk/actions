# Find and fix Open Source vulnerabilities with Snyk

You can use [Snyk](https://snyk.co/SnykGHGuide) to scan your applications' open source dependencies for security, license, and dependency health issues as part of your continuous integration \(CI\) workflow.

{% hint style="info" %}
GitHub Actions is available with GitHub Free, GitHub Pro, GitHub Free for organizations, GitHub Team, GitHub Enterprise Cloud, GitHub Enterprise Server, and GitHub One. GitHub Actions is not available for private repositories owned by accounts using legacy per-repository plans. For more information, see "[GitHub's products](https://docs.github.com/articles/github-s-products)."
{% endhint %}

## In this article

* Introduction
* Prerequisites
* Scanning files with Snyk Open Source
* Adjusting severity thresholds for Snyk Open Source
* Uploading scan results to the Snyk UI

## Introduction

This guide explains how to use GitHub Actions to create a workflow that scans your application's open source dependencies for vulnerabilities with [Snyk Open Source](https://snyk.co/SnykOpenSource). It also covers setting severity thresholds for the Snyk check, and uploading results to the Snyk UI.

## Prerequisites

Create a GitHub Actions secret named `SNYK_TOKEN` to store the value for your Snyk Token. You can retrieve it from your [Snyk account settings](https://snyk.co/SnykSignUpGitHubGuide) or with the [Snyk CLI](https://snyk.co/SnykCLI):

```text
snyk config get api
```

For more information on creating secrets for GitHub Actions, see "[Encrypted secrets](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository)."

This guide assumes that you have an application containing open source dependencies in a GitHub repository. We recommend that you have a basic understanding of workflow configuration options and how to create a workflow file. For more information, see "[Learn GitHub Actions](https://docs.github.com/en/actions/learn-github-actions)."

## Scanning with Snyk Open Source

As part of your CI workflow to build your application, you can trigger a workflow to check it for security issues. The workflow in the example below runs when the `pull request` event is triggered. For more information on the `pull request` event, see "[Events that trigger workflows](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#pull_request)".

In the example workflow below, we use the `Snyk` action to scan the dependencies specified in a Node.js application's `package.json` file for vulnerabilities and other risks.

The Snyk Action has properties that are passed to the underlying image using `with`:

* `args` : override the default arguments to the Snyk image
* `command`: defaults to `test`, specify which command to run
* `json` : defaults to `false`, save the results as `snyk.json`

```text
name: Scan a Node app for vulnerabilities using Snyk 
on: pull_request
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Snyk Test Vulnerabilities
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ Secrets.SNYK_TOKEN }}
```

Whenever a Pull Request is opened, this workflow checks out the code and uses the Snyk Action to scan for vulnerable open source dependencies. Snyk fails the check if any vulnerabilities are found.

## Adjusting severity thresholds for Snyk Open Source

You can adjust the severity level of the issues Snyk uses to determine wether to pass the check. For example, you can choose to fail only when high severity issues are found. This is accomplished with the `--severity-threshold` property. Accepted values are `high`, `medium`, and `low`.

```text
name: Scan a Node app for vulnerabilities using Snyk 
on: pull_request
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Snyk Test for High Severity Vulnerabilities
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ Secrets.SNYK_TOKEN }}
        args: --severity-threshold=high
```

Whenever a Pull Request is opened, this workflow checks out the code and uses the Snyk Action to scan for vulnerable open source dependencies. If any have High Severity vulnerabilities, Snyk fails the check.

## Uploading scan results to the Snyk UI

The default command used by the Snyk Actions is `snyk test`. Changing it to `snyk monitor` uploads a snapshot of our dependencies to the Snyk UI for continuous monitoring. This ensures we're notified of any new vulnerabilities disclosed for our open source components.

For this last example, we'll upload a snapshot of our application dependencies to Snyk on the `release` event; for more information see "[Events that trigger workflows](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#release)".

```text
name: Upload a Snapshot of Open Source dependencies to Snyk
on:
  release:
    types: [published]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Upload Dependency Scan to Snyk Monitor
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ Secrets.SNYK_TOKEN }}
        with:
          command: monitor
```

When a new release in published, this workflow uploads a snapshot of the application's open source dependencies to the Snyk UI for continuous monitoring and alerting on newly disclosed vulnerabilities.

## Additional Resources

For more information on Snyk Container, including best practices and other examples, check out:

* [Snyk Open Source Security Blog](https://snyk.co/SnykBlog)
* Official [Snyk CLI Cheat Sheet](https://snyk.co/CLIcheatsheet)
* Lab: [Securing a Toolchain with Snyk and GitHub](https://snyk.co/SecureToolChain)


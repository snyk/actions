# Scan Container Images for Vulnerabilities with Snyk Container

You can use [Snyk Container](https://snyk.co/Container) to scan your container images for vulnerabilities as part of your continuous integration \(CI\) workflow.

{% hint style="info" %}
GitHub Actions is available with GitHub Free, GitHub Pro, GitHub Free for organizations, GitHub Team, GitHub Enterprise Cloud, GitHub Enterprise Server, and GitHub One. GitHub Actions is not available for private repositories owned by accounts using legacy per-repository plans. For more information, see "[GitHub's products](https://docs.github.com/articles/github-s-products)."
{% endhint %}

## In this article

* Introduction
* Prerequisites
* Scanning files with Snyk Container
* Adjusting severity thresholds for Snyk Container
* Uploading Snyk Container scan results to GitHub Security

## Introduction

This guide explains how to use GitHub Actions to create a workflow that scans a container image for vulnerabilities with [Snyk Container.](https://snyk.co/Container) It also covers setting severity thresholds for the Container check, and uploading results to GitHub Security.

## Prerequisites

Create a GitHub Actions secret named `SNYK_TOKEN` to store the value for your Snyk Token. You can retrieve it from your [Snyk account settings](https://snyk.co/SnykSignUpGitHubGuide) or with the [Snyk CLI:](https://snyk.co/SnykCLI)

```text
snyk config get api
```

For more information on creating secrets for GitHub Actions, see "[Encrypted secrets](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository)."

This guide assumes that you have a complete definition and any other files needed to create a container image stored in a GitHub repository. We recommend that you have a basic understanding of workflow configuration options and how to create a workflow file. For more information, see "[Learn GitHub Actions](https://docs.github.com/en/actions/learn-github-actions)."

## Scanning with Snyk Container

As part of your CI workflow to build your container image, you can trigger a workflow to check it for security issues. The workflow in the example below runs when the `pull request` event is triggered. For more information on the `pull request` event, see "[Events that trigger workflows](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#pull_request)".

In the example workflow below, we use the `Snyk Container` action to scan the container image packaging our application and the `Dockerfile` used to build it.

The `Snyk Container` Action has properties that are passed to the underlying image using `with`:

* `args` : override the default arguments to the Snyk Container image
* `command`: defaults to `test`, specify which command to run
* `image` : the name of the image to test
* `json` : defaults to `false`, save the results as `snyk.json`
* `sarif`: default to `true`, save the results as `snyk.sarif`

```text
name: Build Image and scan for Vulnerabilities with Snyk Container
on: pull_request
jobs:
  build_scan_container:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Setup up Docker Buildx
        uses: docker/setup-buildx-action@v1
      - name: Build Docker Image
        uses: docker/build-push-action@v2
        with:
          push: false
          load: true
          tags: my-org/my-repo/my-image
      - name: Snyk Container Test
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ Secrets.SNYK_TOKEN }}
        with:
          image: my-org/my-repo/my-image
          args: --file=Dockerfile
```

The above workflow checks out the GitHub repository, builds it with Docker Buildx, and uses the Snyk Container Action to scan the image and the `Dockerfile` that built it for issues. Snyk fails the check if any issues are found.

## Adjusting severity thresholds for Snyk Container

You can adjust the severity level of the issues Snyk uses to determine wether to pass the check. For example, you can choose to fail only when high severity issues are found. This is accomplished with the `--severity-threshold` property. Accepted values are `high`, `medium`, and `low`.

```text
name: Publish Image and scan for Vulnerabilities with Snyk Container
on: pull_request
jobs:
  build_scan_container:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Setup up Docker Buildx
        uses: docker/setup-buildx-action@v1
      - name: Build Docker Image
        uses: docker/build-push-action@v2
        with:
          push: false
          load: true
          tags: my-org/my-repo/my-image
      - name: Snyk Container Test for High Severity Vulnerabilities
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ Secrets.SNYK_TOKEN }}
        with:
          image: my-org/my-repo/my-image
          args: --file=Dockerfile --severity-threshold=high
```

The above workflow triggers whenever a Pull Request is opened and checks out the code, builds the container image with Docker Buildx, and scans it with Snyk Container. If the container image has any High Severity vulnerabilities, Snyk will fail the check.

## Uploading Snyk Container scan results to GitHub Security

The Snyk Container Action also supports integrating with GitHub Security. When run, a `snyk.sarif` file will be generated which can be uploaded to GitHub Security to show issues in the repo's Security tab..

For this last example, we'll scan the image on the `release` event; for more information see "[Events that trigger workflows](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#release)". By default, Snyk Container breaks the workflow when issues are present. You can continue the workflow to always upload results to GitHub Security by setting `continue-on-error`to true. 

```text
name: Publish Image and update Snyk Container scan results in GitHub Security
on:
  release:
    types: [published]
jobs:
  push_to_registry:
    name: Push Docker image to GitHub Container Registry
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Setup up Docker Buildx
        uses: docker/setup-buildx-action@v1
      - name: Authenticate to GitHub Container Registry
        uses: docker/login-action@v1
        with:
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Build Docker Image
        id: docker_build
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: docker.pkg.github.com/my-org/my-repo/my-image:latest
  container_security:
    name: Update GitHub Security with Snyk Container scan results
    runs-on: ubuntu-latest
    steps:
      - name: Authenticate to GitHub Container Registry
        uses: docker/login-action@v1
        with:
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Snyk Container Scan
        continue-on-error: true
        uses: snyk/actions/docker@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          image: docker.pkg.github.com/my-org/my-repo/my-image:latest
          args: --file=Dockerfile --severity-threshold=high
      - name: Upload result to GitHub Code Scanning
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: snyk.sarif
```

The above workflow checks out the code, builds the container image, pushes it to GitHub Container Registry, then scans with Snyk Container to upload high severity vulnerabilities into the repo's Security tab.

## Additional Resources

For more information on Snyk Container, including best practices and other examples, check out:

* [Snyk Guide to Container Security](https://snyk.co/GuidetoContainerSecurity)
* Official [Snyk CLI Cheat Sheet](https://snyk.co/CLIcheatsheet)
* Lab: [Securing a Toolchain with Snyk and GitHub](https://solutions.snyk.io/partner-workshops/github/securing-a-toolchain-with-snyk-and-github)


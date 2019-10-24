# Snyk Docker Action

A [GitHub Action](https://github.com/features/actions) for using [Snyk](https://snyk.io) to check for
vulnerabilities in your Docker images.

You can use the Action as follows:

```yaml
name: Example workflow for Docker using Snyk 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - name: Run Snyk to check Docker image for vulnerabilities
      uses: snyk/actions/docker@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        image: your/image-to-test
```

The Snyk Docker Action has properties which are passed to the underlying image. These are
passed to the action using `with`.

| Property | Default | Description |
| --- | --- | --- |
| args |   | Override the default arguments to the Snyk image |
| command | test | Specifiy which command to run, for instance test or monitor |
| image |    | The name of the image to test |

For example, you can choose to only report on high severity vulnerabilities.

```yaml
name: Example workflow for Docker using Snyk 
on: push
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - name: Run Snyk to check Docker images for vulnerabilities
      uses: snyk/actions/docker@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        image: your/image-to-test
        args: --severity-threshold=high
```

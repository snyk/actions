#!/bin/bash
set -e

# This script takes two positional arguments. The first is the version of Snyk to install.
# This can be a standard version (ie. v1.390.0) or it can be latest, in which case the
# latest released version will be used.
#
# The second argument is the platform, in the format used by the `runner.os` context variable
# in GitHub Actions. Note that this script does not currently support Windows based environments.
#
# As an example, the following would install the latest version of Snyk for GitHub Actions for
# a Linux runner:
#
#     ./snyk-setup.sh latest Linux
#

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 2 ] || die "Setup Snyk requires two argument, $# provided"

cd "$(mktemp -d)"

echo "Installing the $1 version of Snyk on $2"

VERSION=$1
BASE_URL="https://static.snyk.io/cli"
SNYK_PATH="${HOME}/.local/snyk/bin"

case "$2" in
    Linux)
        PREFIX=linux
        ;;
    Windows)
        die "Windows runner not currently supported"
        ;;
    macOS)
        PREFIX=macos
        ;;
    *)
        die "Invalid running specified: $2"
esac

mkdir -p "${SNYK_PATH}" 2>/dev/null

{
    echo "#!/bin/bash"
    echo export SNYK_INTEGRATION_NAME="GITHUB_ACTIONS"
    echo export SNYK_INTEGRATION_VERSION=\"setup \(${2}\)\"
    echo export FORCE_COLOR=2
    echo eval snyk-${PREFIX} \$@
} > snyk

chmod +x snyk
mv snyk "${SNYK_PATH}"

curl --compressed --retry 2 --output snyk-${PREFIX} "$BASE_URL/$VERSION/snyk-${PREFIX}"
curl --compressed --retry 2 --output snyk-${PREFIX}.sha256 "$BASE_URL/$VERSION/snyk-${PREFIX}.sha256"

sha256sum -c snyk-${PREFIX}.sha256
chmod +x snyk-${PREFIX}
mv snyk-${PREFIX} "${SNYK_PATH}"
rm -rf snyk*

echo "${SNYK_PATH}" >> "${GITHUB_PATH}"
export PATH="${SNYK_PATH}":"${PATH}"

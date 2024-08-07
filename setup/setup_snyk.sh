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
SUDO_CMD="sudo"

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
    Alpine)
        PREFIX=alpine
        ;;
    *)
        die "Invalid runner specified: $2"
esac

{
    echo "#!/bin/bash"
    echo export SNYK_INTEGRATION_NAME="GITHUB_ACTIONS"
    echo export SNYK_INTEGRATION_VERSION=\"setup \(${2}\)\"
    echo export FORCE_COLOR=2
    echo eval snyk-${PREFIX} \$@
} > snyk

if ! command -v "$SUDO_CMD" &> /dev/null; then
  echo "$SUDO_CMD is NOT installed. Trying without sudo, expecting privileges to write to '/usr/local/bin'."
  SUDO_CMD=""
else
    echo "$SUDO_CMD is installed."
fi

chmod +x snyk
${SUDO_CMD} mv snyk /usr/local/bin

curl --compressed --retry 2 --output snyk-${PREFIX} "$BASE_URL/$VERSION/snyk-${PREFIX}" 
curl --compressed --retry 2 --output snyk-${PREFIX}.sha256 "$BASE_URL/$VERSION/snyk-${PREFIX}.sha256"

sha256sum -c snyk-${PREFIX}.sha256
chmod +x snyk-${PREFIX}
${SUDO_CMD} mv snyk-${PREFIX} /usr/local/bin
rm -rf snyk*

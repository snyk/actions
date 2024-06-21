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

VERSION=$(echo "$1" | cut -d'v' -f2)
BINARY_NAME=snyk-actual
{
    echo "#!/bin/bash"
    echo export SNYK_INTEGRATION_NAME="GITHUB_ACTIONS"
    echo export SNYK_INTEGRATION_VERSION=\"setup \("${2}"\)\"
    echo export FORCE_COLOR=2
    echo eval $BINARY_NAME \$@
} > snyk

chmod +x snyk
sudo mv snyk /usr/local/bin || mv snyk /c/Windows/System32


curl -sSL --compressed --output install-snyk.py https://raw.githubusercontent.com/snyk/cli/master/scripts/install-snyk.py
chmod +x install-snyk.py
PIP_BREAK_SYSTEM_PACKAGES=1 pip3 install requests --quiet || PIP_BREAK_SYSTEM_PACKAGES=1 pip install requests --quiet
python3 install-snyk.py "$VERSION" || python install-snyk.py "$VERSION"

sudo mv snyk /usr/local/bin/"$BINARY_NAME" || mv snyk /c/Windows/System32/"$BINARY_NAME"
rm -rf snyk*
rm -f install-snyk.py
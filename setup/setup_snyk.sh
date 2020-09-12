#!/bin/bash
set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "Setup Snyk requires a single argument, $# provided"

echo "Installing the $1 version of Snyk"

if [ "$1" == "latest" ]; then
    URL="https://api.github.com/repos/snyk/snyk/releases/${1}"
else
    URL="https://api.github.com/repos/snyk/snyk/releases/tags/${1}"
fi

{
    echo "#!/bin/bash"
    echo export SNYK_INTEGRATION_NAME="GITHUB_ACTIONS"
    echo export SNYK_INTEGRATION_VERSION="setup"
    echo eval snyk-linux \$@
} > snyk

chmod +x snyk
sudo mv snyk /usr/local/bin

wget -qO- ${URL} | grep "browser_download_url" | grep linux | cut -d '"' -f 4 | wget --progress=bar:force:noscroll -i -

sha256sum -c snyk-linux.sha256
chmod +x snyk-linux
sudo mv snyk-linux /usr/local/bin


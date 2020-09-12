#!/bin/bash
set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "Setup Snyk requires a single argument, $# provided"

echo "Installing the $1 version of Snyk"

wget -qO- https://api.github.com/repos/snyk/snyk/releases/${1} | grep "browser_download_url" | grep linux | cut -d '"' -f 4 | wget --progress=bar:force:noscroll -i - && \
    sha256sum -c snyk-linux.sha256 && \
    chmod +x snyk-linux && \
    sudo mv snyk-linux /usr/local/bin/snyk

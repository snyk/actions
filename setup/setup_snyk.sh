#!/bin/bash
set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 2 ] || die "Setup Snyk requires two argument, $# provided"

echo "Installing the $1 version of Snyk on $2"

if [ "$1" == "latest" ]; then
    URL="https://api.github.com/repos/snyk/snyk/releases/${1}"
else
    URL="https://api.github.com/repos/snyk/snyk/releases/tags/${1}"
fi

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

{
    echo "#!/bin/bash"
    echo export SNYK_INTEGRATION_NAME="GITHUB_ACTIONS"
    echo export SNYK_INTEGRATION_VERSION="setup (${2})"
    echo eval snyk-${PREFIX} \$@
} > snyk

chmod +x snyk
sudo mv snyk /usr/local/bin

wget -qO- ${URL} | grep "browser_download_url" | grep $PREFIX | cut -d '"' -f 4 | wget --progress=bar:force:noscroll -i -

sha256sum -c snyk-${PREFIX}.sha256
chmod +x snyk-${PREFIX}
sudo mv snyk-${PREFIX} /usr/local/bin

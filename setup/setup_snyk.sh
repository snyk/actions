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

echo_with_timestamp() {
    echo "$(date +%Y-%m-%dT%H:%M:%SZ) $1"
}

die () {
    echo_with_timestamp >&2 "$@"
    exit 1
}

# Check if correct number of arguments is provided
[ "$#" -eq 2 ] || die "Setup Snyk requires two arguments, $# provided"

cd "$(mktemp -d)"
echo_with_timestamp "Installing the $1 version of Snyk on $2"

VERSION=$1
MAIN_URL="https://downloads.snyk.io/cli"
BACKUP_URL="https://static.snyk.io/cli"
SUDO_CMD="sudo"
GH_ACTIONS="GITHUB_ACTIONS"

# Determine the prefix based on the platform
case "$2" in
    Linux)   PREFIX=linux ;;
    macOS)   PREFIX=macos ;;
    Alpine)  PREFIX=alpine ;;
    Windows) die "Windows runner not currently supported" ;;
    *)       die "Invalid runner specified: $2" ;;
esac

{
    echo_with_timestamp "#!/bin/bash"
    echo_with_timestamp export SNYK_INTEGRATION_NAME=\"$GH_ACTIONS\"
    echo_with_timestamp export SNYK_INTEGRATION_VERSION=\"setup \(${2}\)\"
    echo_with_timestamp export FORCE_COLOR=2
    echo_with_timestamp eval snyk-${PREFIX} \$@
} > snyk

if ! command -v "$SUDO_CMD" &> /dev/null; then
  echo_with_timestamp "$SUDO_CMD is NOT installed. Trying without sudo, expecting privileges to write to '/usr/local/bin'."
  SUDO_CMD=""
else
    echo_with_timestamp "$SUDO_CMD is installed."
fi

chmod +x snyk
${SUDO_CMD} mv snyk /usr/local/bin
# Function to download a file with fallback to backup URL
# Parameters:
#   $1: File name to download
#   $2: Output file name
download_file() {
    # Try to download from the main URL
    if curl --compressed --retry 2 --output "$2" "$MAIN_URL/$1?utm_source="$GH_ACTIONS; then
        echo_with_timestamp "Downloaded from $MAIN_URL/$1?utm_source=$GH_ACTIONS"
    # If main URL fails, try the backup URL
    elif curl --compressed --retry 2 --output "$2" "$BACKUP_URL/$1?utm_source="$GH_ACTIONS; then
        echo_with_timestamp "Downloaded from $BACKUP_URL/$1?utm_source=$GH_ACTIONS"
    # If both URLs fail, return an error
    else
        echo_with_timestamp "Failed to download $1 from both URLs"
        return 1
    fi
}

echo_with_timestamp "Download Snyk binary"
if ! download_file "$VERSION/snyk-${PREFIX}" "snyk-${PREFIX}"; then
    die "Failed to download Snyk binary"
fi

echo_with_timestamp "Download SHA256 checksum file"
if ! download_file "$VERSION/snyk-${PREFIX}.sha256" "snyk-${PREFIX}.sha256"; then
    die "Failed to download SHA256 file"
fi

# Verify the checksum
echo_with_timestamp "Validating shasum"
if ! sha256sum -c snyk-${PREFIX}.sha256; then
    echo_with_timestamp "Actual: "
    sha256sum snyk-${PREFIX}

    echo_with_timestamp "Expected: "
    cat snyk-${PREFIX}.sha256

    die "Shasum validation failed"
fi


echo_with_timestamp "Moving and cleaning files"
# Make the binary executable
chmod +x snyk-${PREFIX}

# Move the binary to /usr/local/bin
${SUDO_CMD} mv snyk-${PREFIX} /usr/local/bin
rm -rf snyk*

echo_with_timestamp "Finished"

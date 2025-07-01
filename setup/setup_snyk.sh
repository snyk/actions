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
    echo "#!/bin/bash"
    echo export SNYK_INTEGRATION_NAME=\"$GH_ACTIONS\"
    echo export SNYK_INTEGRATION_VERSION=\"setup \(${2}\)\"
    echo export FORCE_COLOR=2
    echo eval snyk-${PREFIX} \$@
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
#   $1: Download URL
#   $2: Output file name
download_file() {
    echo_with_timestamp "Downloading files from $1"
    if curl --fail -D - --compressed --retry 2 --output "$2" "$1/$2?utm_source="$GH_ACTIONS; then
        echo_with_timestamp "Downloaded binary from $1/$2?utm_source=$GH_ACTIONS"
    else
        echo_with_timestamp "Failed to download binary from $1/$2?utm_source=$GH_ACTIONS"
        return 1
    fi

    if curl --fail -D - --compressed --retry 2 --output "$2.sha256" "$1/$2.sha256?utm_source="$GH_ACTIONS; then
        echo_with_timestamp "Downloaded shasum from $1/$2.sha256?utm_source=$GH_ACTIONS"
    else
        echo_with_timestamp "Failed to download shasum from $1/$2.sha256?utm_source=$GH_ACTIONS"
        return 1
    fi

    echo_with_timestamp "Validating shasum"
    if ! sha256sum -c snyk-${PREFIX}.sha256; then
        echo_with_timestamp "Actual: "
        sha256sum snyk-${PREFIX}

        echo_with_timestamp "Expected: "
        cat snyk-${PREFIX}.sha256

        echo_with_timestamp "Shasum validation failed"
        return 1
    fi
}

if ! download_file "$MAIN_URL/$VERSION" "snyk-${PREFIX}"; then
    echo_with_timestamp "Failed to download and validate Snyk files"
    
    echo_with_timestamp "Retrying download with secondary URL"
    if ! download_file "$BACKUP_URL/$VERSION" "snyk-${PREFIX}"; then
        die "Failed to download and validate Snyk files"
    fi
fi


# Make the binary executable
chmod +x snyk-${PREFIX}

echo_with_timestamp "Moving and cleaning files"
# Move the binary to /usr/local/bin
${SUDO_CMD} mv snyk-${PREFIX} /usr/local/bin
rm -rf snyk*

echo_with_timestamp "Installed Snyk v$(snyk -v)"

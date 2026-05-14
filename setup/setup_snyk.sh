#!/bin/bash
set -e

# This script takes two or three positional arguments. The first is the version
# of Snyk to install. This can be a standard version (ie. v1.390.0) or it can
# be latest, in which case the latest released version will be used.
#
# The second argument is the platform, in the format used by the `runner.os`
# context variable in GitHub Actions. Note that this script does not currently
# support Windows based environments.
#
# The third argument is optional and specifies the CPU architecture, in the
# format used by the `runner.arch` context variable in GitHub Actions (e.g.
# X64, ARM64). When omitted, the architecture is auto-detected from `uname -m`.
#
# As an example, the following would install the latest version of Snyk for
# GitHub Actions for a Linux x86_64 runner:
#
#     ./setup_snyk.sh latest Linux
#
# And for a Linux arm64 runner:
#
#     ./setup_snyk.sh latest Linux ARM64
#

echo_with_timestamp() {
    echo "$(date +%Y-%m-%dT%H:%M:%SZ) $1"
}

die () {
    echo_with_timestamp >&2 "$@"
    exit 1
}

# Check if correct number of arguments is provided
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    die "Setup Snyk requires 2 or 3 arguments, $# provided"
fi

cd "$(mktemp -d)"
echo_with_timestamp "Installing the $1 version of Snyk on $2 ${3:-$(uname -m)}"

VERSION=$1
RUNNER_OS=$2
RUNNER_ARCH="${3:-$(uname -m)}"
MAIN_URL="https://downloads.snyk.io/cli"
BACKUP_URL="https://static.snyk.io/cli"
SUDO_CMD="sudo"
GH_ACTIONS="GITHUB_ACTIONS"

# Determine the OS prefix
case "$RUNNER_OS" in
    Linux)   PREFIX=linux ;;
    macOS)   PREFIX=macos ;;
    Alpine)  PREFIX=alpine ;;
    Windows) die "Windows runner not currently supported" ;;
    *)       die "Invalid runner specified: $RUNNER_OS" ;;
esac

# Determine the arch suffix. Snyk publishes arm64 binaries for linux, macos,
# and alpine.
case "$RUNNER_ARCH" in
    X64|x64|x86_64|amd64)
        ARCH_SUFFIX="" ;;
    ARM64|arm64|aarch64)
        case "$PREFIX" in
            linux|macos|alpine) ARCH_SUFFIX="-arm64" ;;
            *)                  die "No arm64 binary available for $RUNNER_OS" ;;
        esac
        ;;
    *)
        die "Invalid architecture specified: $RUNNER_ARCH" ;;
esac

BINARY="snyk-${PREFIX}${ARCH_SUFFIX}"

{
    echo "#!/bin/bash"
    echo export SNYK_INTEGRATION_NAME=\"$GH_ACTIONS\"
    echo export SNYK_INTEGRATION_VERSION=\"setup \(${RUNNER_OS}\)\"
    echo export FORCE_COLOR=2
    echo eval ${BINARY} \$@
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
    if ! sha256sum -c ${BINARY}.sha256; then
        echo_with_timestamp "Actual: "
        sha256sum ${BINARY}

        echo_with_timestamp "Expected: "
        cat ${BINARY}.sha256

        echo_with_timestamp "Shasum validation failed"
        return 1
    fi
}

if ! download_file "$MAIN_URL/$VERSION" "${BINARY}"; then
    echo_with_timestamp "Failed to download and validate Snyk files"

    echo_with_timestamp "Retrying download with secondary URL"
    if ! download_file "$BACKUP_URL/$VERSION" "${BINARY}"; then
        die "Failed to download and validate Snyk files"
    fi
fi


# Make the binary executable
chmod +x ${BINARY}

echo_with_timestamp "Moving and cleaning files"
# Move the binary to /usr/local/bin
${SUDO_CMD} mv ${BINARY} /usr/local/bin
rm -rf snyk*

echo_with_timestamp "Installed Snyk v$(snyk -v)"

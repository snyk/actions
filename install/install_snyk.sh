#!/bin/bash
set -e

wget -qO- https://api.github.com/repos/snyk/snyk/releases/latest | grep "browser_download_url" | grep linux | cut -d '"' -f 4 | wget -i - && \
    sha256sum -c snyk-linux.sha256 && \
    mv snyk-linux /usr/local/bin/snyk && \
    chmod +x /usr/local/bin/snyk

#!/bin/bash

# Installs gtv in your system for all users or updates the gtv script
# if applicable. Needs root privileges.

################################################################################

# MIT License
#
# Copyright (c) 2017 Johannes Layher
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

################################################################################

INSTALL_PATH="/usr/local/bin"
GTV_RELEASE_URL="https://api.github.com/repos/jola5/gtv/releases"
VERSION_GREP="([0-9].){2}[0-9]"

# version comparison thanks to https://stackoverflow.com/a/4024263
function verlte() {
    [ "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

function verlt() {
  [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

function isAlreadyInstalled() {
  [ -f "${INSTALL_PATH}/git-tag-version" ]
}

function scriptNeedsUpdating() {
  latestVersion=$(curl -s ${GTV_RELEASE_URL} | grep tag_name | head -1 | grep -oE ${VERSION_GREP})
  installedVersion=$(git-tag-version version | grep -oE ${VERSION_GREP})
  verlt ${installedVersion} ${latestVersion}
}

function deleteExistingVersion() {
  rm -rf "${INSTALL_PATH}/gtv" "${INSTALL_PATH}/git-tag-version"
}

function installLatestVersion() {
  echo "installing gtv"
  curl -sL $(curl -s ${GTV_RELEASE_URL} | grep browser_download_url | head -n 1 | cut -d '"' -f 4) --output "${INSTALL_PATH}/git-tag-version"
  chmod +x "${INSTALL_PATH}/git-tag-version"
  ln -s "${INSTALL_PATH}/git-tag-version" "${INSTALL_PATH}/gtv"
}

function updateVersion() {
  echo "updating gtv"
  deleteExistingVersion
  installLatestVersion
}

function alreadyLatestVersion() {
  echo "gtv is already the latest version installed"
}

if ! isAlreadyInstalled; then
  installLatestVersion
else
  if scriptNeedsUpdating; then
    updateVersion
  else
    alreadyLatestVersion
  fi
fi

echo "$(gtv version) is available"

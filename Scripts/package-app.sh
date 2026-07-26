#!/bin/bash
#
# Builds DynamicSignatureManager.app from the Swift package.
#
# Usage: Scripts/package-app.sh [--debug]
#
# Output: build/DynamicSignatureManager.app
# The bundle is ad-hoc signed, which is enough for local use (the
# Automation permission for controlling Mail requires a stable signature).

set -euo pipefail
cd "$(dirname "$0")/.."

CONFIGURATION="release"
if [[ "${1:-}" == "--debug" ]]; then
    CONFIGURATION="debug"
fi

# Prefer the full Xcode toolchain when only the CLT is selected, since the
# CLT cannot run the test suite (no Testing module).
if ! xcode-select -p | grep -q "Xcode.app" && [[ -d "/Applications/Xcode.app" ]]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

echo "Building (${CONFIGURATION})..."
swift build -c "${CONFIGURATION}"

APP="build/DynamicSignatureManager.app"
BINARY=".build/${CONFIGURATION}/DynamicSignatureManager"

rm -rf "${APP}"
mkdir -p "${APP}/Contents/MacOS" "${APP}/Contents/Resources"
cp "${BINARY}" "${APP}/Contents/MacOS/DynamicSignatureManager"
cp Support/Info.plist "${APP}/Contents/Info.plist"

codesign --force --sign - "${APP}"

echo
echo "Built ${APP}"
echo "Install: mv it to /Applications, then launch it from Finder."

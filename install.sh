#!/usr/bin/env bash
# Install mc-cli from GitHub releases with checksum verification
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/hugeai-inc/homebrew-tap/main/install.sh | sh
#   or: curl -fsSL https://raw.githubusercontent.com/hugeai-inc/homebrew-tap/main/install.sh | sh -s -- --version v0.5.0
#
# This script downloads the latest mc-cli release for your platform, verifies its SHA256 checksum,
# and installs it to /usr/local/bin (or $PREFIX if set). It requires curl, shasum (or sha256sum), and tar.

set -euo pipefail

# Configuration
# Archives are published on this public tap because hugeai-inc/mission-control is private.
REPO="hugeai-inc/homebrew-tap"
BINARY_NAME="mc"
PACKAGE_NAME="mc-cli"
PREFIX="${PREFIX:-/usr/local}"
INSTALL_DIR="${PREFIX}/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { printf '%b%s%b %s\n' "$GREEN" "==>" "$NC" "$*"; }
warn() { printf '%b%s%b %s\n' "$YELLOW" "Warning:" "$NC" "$*" >&2; }
error() { printf '%b%s%b %s\n' "$RED" "Error:" "$NC" "$*" >&2; exit 1; }

# Detect OS and architecture
detect_platform() {
  local os arch
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  case "$os" in
    linux) os="linux" ;;
    darwin) os="darwin" ;;
    mingw*|msys*|cygwin*) os="windows" ;;
    *) error "Unsupported OS: $os" ;;
  esac

  arch=$(uname -m)
  case "$arch" in
    x86_64|amd64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) error "Unsupported architecture: $arch" ;;
  esac

  echo "${os}_${arch}"
}

# Get latest release version from GitHub
get_latest_version() {
  local version
  version=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | \
    grep -o '"tag_name": *"mc-cli/v[^"]*"' | \
    head -n1 | \
    sed 's/"tag_name": *"mc-cli\/v\([^"]*\)"/\1/')

  if [ -z "$version" ]; then
    error "Could not determine latest version"
  fi
  echo "$version"
}

# Parse command line arguments
VERSION=""
while [ $# -gt 0 ]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    *)
      error "Unknown option: $1"
      ;;
  esac
done

# Main installation
main() {
  log "Installing ${PACKAGE_NAME}..."

  # Detect platform
  local platform
  platform=$(detect_platform)
  log "Detected platform: $platform"

  # Get version
  if [ -z "$VERSION" ]; then
    VERSION=$(get_latest_version)
    log "Using latest version: $VERSION"
  else
    # Remove leading 'v' if present
    VERSION="${VERSION#v}"
    log "Using specified version: $VERSION"
  fi

  # Construct download URLs. The tag is mc-cli/vX.Y.Z; encode the slash so GitHub can resolve it.
  local archive="${PACKAGE_NAME}_${VERSION}_${platform}.tar.gz"
  local base_url="https://github.com/${REPO}/releases/download/mc-cli%2Fv${VERSION}"
  local archive_url="${base_url}/${archive}"
  local checksums_url="${base_url}/SHA256SUMS"

  # Create temporary directory
  local tmpdir
  tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" EXIT

  log "Downloading $archive..."
  if ! curl -fsSL -o "${tmpdir}/${archive}" "$archive_url"; then
    error "Failed to download ${archive} from ${archive_url}"
  fi

  log "Downloading checksums..."
  if ! curl -fsSL -o "${tmpdir}/SHA256SUMS" "$checksums_url"; then
    error "Failed to download SHA256SUMS from ${checksums_url}"
  fi

  # Verify checksum
  log "Verifying checksum..."
  cd "$tmpdir"

  # Extract the relevant checksum
  local expected_checksum
  expected_checksum=$(grep "${archive}" SHA256SUMS | awk '{print $1}')

  if [ -z "$expected_checksum" ]; then
    error "Checksum not found for ${archive}"
  fi

  # Calculate actual checksum
  local actual_checksum
  if command -v shasum >/dev/null 2>&1; then
    actual_checksum=$(shasum -a 256 "${archive}" | awk '{print $1}')
  elif command -v sha256sum >/dev/null 2>&1; then
    actual_checksum=$(sha256sum "${archive}" | awk '{print $1}')
  else
    error "Neither shasum nor sha256sum found. Cannot verify checksum."
  fi

  if [ "$actual_checksum" != "$expected_checksum" ]; then
    error "Checksum verification failed!
  Expected: $expected_checksum
  Got:      $actual_checksum"
  fi

  log "Checksum verified ✓"

  # Extract binary
  log "Extracting archive..."
  tar -xzf "${archive}"

  # Install binary
  if [ ! -d "$INSTALL_DIR" ]; then
    log "Creating install directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
  fi

  log "Installing ${BINARY_NAME} to ${INSTALL_DIR}..."
  if [ -w "$INSTALL_DIR" ]; then
    mv "${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
    chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
  else
    sudo mv "${BINARY_NAME}" "${INSTALL_DIR}/${BINARY_NAME}"
    sudo chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
  fi

  printf '%b%s%b %s\n' "$GREEN" "==>" "$NC" "✓ ${PACKAGE_NAME} ${VERSION} installed successfully!"
  log ""
  log "Run '${BINARY_NAME} --version' to verify the installation."
  log "Run '${BINARY_NAME} help' to get started."

  # Check if install dir is in PATH
  if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    warn "$INSTALL_DIR is not in your PATH. Add it with:"
    warn "  export PATH=\"${INSTALL_DIR}:\$PATH\""
  fi
}

main "$@"

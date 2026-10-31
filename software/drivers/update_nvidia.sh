#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
TARGET_FILE="$SCRIPT_DIR/nvidia-version.nix"
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force)
      FORCE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-f|--force]" >&2
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [-f|--force]" >&2
      exit 1
      ;;
  esac
done

echo "Fetching latest NVIDIA driver version from GitHub..." >&2
VERSION=$(curl -s "https://api.github.com/repos/NVIDIA/open-gpu-kernel-modules/releases/latest" \
  | grep -Po '"tag_name":\s*"\K[^"]+' || true)

if [[ -z "$VERSION" ]]; then
  echo "Error: Failed to fetch latest version from GitHub." >&2
  exit 1
fi

echo "Latest version is $VERSION" >&2

# Skip hash calculations if not forced and the version already matches
if [[ "$FORCE" != "true" && -f "$TARGET_FILE" ]]; then
  CURRENT_VERSION=$(grep -Po 'version\s*=\s*"\K[^"]+' "$TARGET_FILE" || true)
  if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
    echo "Already at latest version ($VERSION). Skipping update (use --force to rebuild)." >&2
    exit 0
  fi
fi

get_hash() {
  echo "Calculating hash of $1" >&2
  nix-prefetch-url "$1" "${@:2}" --type sha256 2>/dev/null | xargs nix hash convert --to sri --hash-algo sha256
}

HASH_64=$(get_hash "https://download.nvidia.com/XFree86/Linux-x86_64/$VERSION/NVIDIA-Linux-x86_64-$VERSION.run")
HASH_OPEN=$(get_hash "https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/$VERSION.tar.gz" --unpack)
HASH_SETTINGS=$(get_hash "https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/$VERSION.tar.gz" --unpack)
HASH_PERSIST=$(get_hash "https://github.com/NVIDIA/nvidia-persistenced/archive/refs/tags/$VERSION.tar.gz" --unpack)

cat <<EOF | tee "$TARGET_FILE"
{ config, lib, ... }:
{
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "$VERSION";
    sha256_64bit = "$HASH_64";
    openSha256 = "$HASH_OPEN";
    settingsSha256 = "$HASH_SETTINGS";
    persistencedSha256 = "$HASH_PERSIST";
    sha256_aarch64 = lib.fakeHash;
  };
}
EOF

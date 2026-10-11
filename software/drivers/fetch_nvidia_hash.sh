#!/usr/bin/env bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
VERSION="615.78.08"

get_hash() {
  nix-prefetch-url "$1" "${@:2}" --type sha256 2>/dev/null | xargs nix hash convert --to sri --hash-algo sha256
}

HASH_64=$(get_hash "https://download.nvidia.com/XFree86/Linux-x86_64/$VERSION/NVIDIA-Linux-x86_64-$VERSION.run")
HASH_OPEN=$(get_hash "https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/$VERSION.tar.gz" --unpack)
HASH_SETTINGS=$(get_hash "https://github.com/NVIDIA/nvidia-settings/archive/refs/tags/$VERSION.tar.gz" --unpack)
HASH_PERSIST=$(get_hash "https://github.com/NVIDIA/nvidia-persistenced/archive/refs/tags/$VERSION.tar.gz" --unpack)

cat <<EOF | tee "$SCRIPT_DIR/nvidia-version.nix"
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

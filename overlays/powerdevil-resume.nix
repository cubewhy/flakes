{ lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (_: kdePrev: {
        powerdevil = kdePrev.powerdevil.overrideAttrs (
          old:
          lib.optionalAttrs (lib.versionAtLeast old.version "6.8.0" && lib.versionOlder old.version "6.8.4") {
            patches = (old.patches or [ ]) ++ [
              (final.fetchurl {
                name = "powerdevil-513809.patch";
                url = "https://invent.kde.org/plasma/powerdevil/-/commit/5cbacbbf109072996b5cb06bf068a091f1de9d7e.diff";
                hash = "sha256-1Uu4fLR6VR3VGJXw3csW0ydUPNiHw3skaXREBEoTSJQ=";
              })
            ];
          }
        );
      });
    })
  ];
}

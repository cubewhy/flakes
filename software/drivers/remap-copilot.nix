{...}: {
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["0001:0001:09b4e68d"];
        settings = {
          main = {
            "leftshift+leftmeta+f23" = "rightcontrol";
          };
        };
      };
    };
  };

  systemd.services.keyd.serviceConfig = {
    CPUSchedulingPolicy = "fifo";
    CPUSchedulingPriority = 50;

    Nice = -20;

    MemorySwapMax = "0";
    OOMScoreAdjust = -1000;
  };
}

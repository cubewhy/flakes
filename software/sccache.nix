{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.sccache
  ];

  environment.sessionVariables = {
    RUSTC_WRAPPER = "sccache";
    SCCACHE_DIR = "/mnt/data/.sccache";
    SCCACHE_CACHE_SIZE = "40G";
    SCCACHE_IGNORE_SERVER_ERROR = "1";
  };
}

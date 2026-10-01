{ ... }: {
  # Notes: You need to install distrobox manually by
  # curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
  #
  # See https://wiki.nixos.org/wiki/Distrobox#Distrobox_is_not_location_independent and
  # https://github.com/89luca89/distrobox/issues/315 for more details

  environment.etc."distrobox/distrobox.conf".text = ''
    container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
  '';
}

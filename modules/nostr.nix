{
  flake.modules.nixos.nostr = {
    services.nostr-rs-relay = {
      enable = true;
      settings = {
        network.port = 12849;
        database.max_conn = 8;
        info.name = "nostr-backup-relay";
      };
    };
    programs.appimage.enable = true;
  };
}

{
  flake.modules.nixos.backup =
    { config, lib, ... }:
    let
      inherit (lib)
        mkEnableOption
        mkIf
        mkOption
        singleton
        ;
      inherit (lib.types)
        nullOr
        coercedTo
        str
        listOf
        ;
      cfg = config.admasnd.dotfiles.backup;
    in
    {
      options.admasnd.dotfiles.backup = {
        enable = mkEnableOption "backup";
        paths = mkOption {
          type = nullOr (coercedTo str singleton (listOf str));
          description = ''
            Path(s) to back up locally and remotely.

            Sets `services.borgbackup.jobs.borgbase.path` and `services.borgbackup.jobs.localexternal.path`.
          '';
          example = "/home/user";
        };
        exclude = mkOption {
          description = ''
            Exclude paths matching any of the given patterns. See
            `borg help patterns` for pattern syntax.

            Sets `services.borgbackup.jobs.borgbase.exclude` and `services.borgbackup.jobs.localexternal.exclude`.
          '';
          default = [ ];
          example = [
            "/home/*/.cache"
            "/nix"
          ];
        };
        startAt = mkOption {
          type = with lib.types; either str (listOf str);
          default = "daily";
          description = ''
            When or how often the backup should run.

            Must be in the format described in manpage `systemd.time(7)`.
            If you do not want the backup to start automatically, use `[ ]`.
            Sets `services.borgbackup.jobs.borgbase.startAt` and 
            `services.borgbackup.jobs.localexternal.startAt`.
          '';
        };
        remotePublicKey = mkOption {
          type = str;
          description = ''
            Public key of remote backup server to add to ssh known hosts.

            Sets `services.openssh.knownHosts.<host>.publicKey`.
          '';
          example = "ecdsa-sha2-nistp521 AAAAE2VjZHN...UEPg==";
        };
        remotePublicKeyServer = mkOption {
          type = str;
          description = ''
            Server of the remote backup server to add to ssh known hosts.

            Sets `services.openssh.knownHosts.<host>.publicKey`.
          '';
          example = "backup.repo.service.com";
        };
        remoteSecretPath = mkOption {
          type = str;
          description = ''
            path in YAML secrets file where remote backup password stored.

            Sets `services.borgbackup.jobs.borgbase.encryption.passCommand`.
          '';
          example = "path/to/pass";
        };
        localSecretPath = mkOption {
          type = str;
          description = ''
            path in YAML secrets file where local backup password stored.

            Sets `services.borgbackup.jobs.localexternal.encryption.passCommand`.
          '';
          example = "path/to/pass";
        };
        remotePrivateKeyPath = lib.mkOption {
          type = lib.types.str;
          description = ''
            Path to ssh private key associated with remote backup server.

            Sets `services.borgbackup.jobs.borgbase.environment.BORG_RSH`. 
          '';
          example = "/home/user/.ssh/id_borgbase";
        };
        remoteRepo = lib.mkOption {
          type = lib.types.str;
          description = ''
            Remote repository to back up to.

            Sets `services.borgbackup.jobs.borgbase.repo`.
          '';
          example = "user@machine:/path/to/repo";
        };
        localRepo = lib.mkOption {
          type = lib.types.str;
          description = ''
            Local repository to back up to.

            Sets `services.borgbackup.jobs.localexternal.repo`.
          '';
          example = "/run/media/user/USB/borg";
        };
        localRepoMount = lib.mkOption {
          type = lib.types.str;
          description = ''
            Systemd mount point for local backup repository.

            Sets `systemd.services.borgbackup-job-localexternal` and 
            `systemd.timers.borgbackup-job-localexternal`.
          '';
          example = "run-media-user-USB.mount";
        };
      };
      config = mkIf (config.admasnd.dotfiles.sops.enable && cfg.enable) {
        # Instantiate secrets with default options
        sops.secrets.${cfg.remoteSecretPath} = { };
        sops.secrets.${cfg.localSecretPath} = { };

        # Add hostkey for borgbase so that backup service allows connection to borgbase
        # Can use ssh-keyscan -H <server> to get hostkey
        services.openssh.knownHosts.${cfg.remotePublicKeyServer}.publicKey = cfg.remotePublicKey;

        services.borgbackup.jobs.borgbase = {
          paths = cfg.paths;
          exclude = cfg.exclude;
          doInit = false;
          encryption = {
            mode = "repokey-blake2";
            passCommand = "cat ${config.sops.secrets.${cfg.remoteSecretPath}.path}";
          };
          environment.BORG_RSH = "ssh -i ${cfg.remotePrivateKeyPath}";
          repo = cfg.remoteRepo;
          persistentTimer = true;
          inhibitsSleep = true;
          startAt = cfg.startAt;
          extraCreateArgs = [
            "--stats"
            "--verbose"
          ];
        };
        services.borgbackup.jobs.localexternal = {
          paths = cfg.paths;
          exclude = cfg.exclude;
          doInit = false;
          encryption = {
            mode = "repokey-blake2";
            passCommand = "cat ${config.sops.secrets.${cfg.localSecretPath}.path}";
          };
          repo = cfg.localRepo;
          inhibitsSleep = true;
          extraCreateArgs = [
            "--stats"
            "--verbose"
          ];
          removableDevice = true;
          startAt = [ ];
          persistentTimer = true;
        };

        systemd.services.borgbackup-job-localexternal = {
          unitConfig = {
            After = cfg.localRepoMount;
            BindsTo = cfg.localRepoMount;
            ConditionPathIsDirectory = cfg.localRepo;
          };
          wantedBy = [ cfg.localRepoMount ];
        };

        systemd.timers.borgbackup-job-localexternal = {
          unitConfig = {
            After = cfg.localRepoMount;
            BindsTo = cfg.localRepoMount;
          };
          wantedBy = [ cfg.localRepoMount ];
          timerConfig.OnUnitActiveSec = cfg.startAt;
        };
      };
    };
}

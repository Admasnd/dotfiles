{
  flake.modules.nixos.backup =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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
      breakStaleLock = ''
        break_stale_lock() {
          local lockpath="$1"
          # Skip if nothing exists at all
          [ -e "$lockpath" ] || [ -L "$lockpath" ] || return 0

          # Handle regular file or symlink (shouldn't exist, but clean it up)
          if [ -L "$lockpath" ] || [ -f "$lockpath" ]; then
            echo "Unexpected: $lockpath is a file/symlink, not a directory. Removing."
            rm -f "$lockpath"
            return 0
          fi

          # Now we know it's a directory (or should be)
          if [ ! -d "$lockpath" ]; then
            echo "Cannot determine type of $lockpath, skipping"
            return 0
          fi

          # Check for id files inside the lock directory
          local found_idfile=0
          local active_lock=0
          for idfile in "$lockpath"/*; do
            # Handle empty glob — no id files means empty directory
            [ -e "$idfile" ] || continue
              
            local basename=$(basename "$idfile")
            # Skip lock.roster or other non-id files
            echo "$basename" | grep -qE '^[^@]+@.+\.pid[0-9]+\.thread[0-9]+' || continue

            found_idfile=1
            local lock_host=$(echo "$basename" | grep -oP '^[^@]+')
            local lock_pid=$(echo "$basename" | grep -oP 'pid\K\d+')
            local current_host=$(${pkgs.inetutils}/bin/hostname)

            if [ "$lock_host" != "$current_host" ]; then
              echo "Lock from different host '$lock_host', skipping"
              active_lock=1
              continue
            fi

            if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
              echo "Lock held by active PID $lock_pid, aborting" >&2
              active_lock=1
            fi
          done

          # If any active lock was found, abort entirely
          if [ "$active_lock" -eq 1 ]; then
            echo "Active lock detected at $lockpath. Aborting backup."
          exit 1
          fi

          # If no id files found — empty directory.
          # This is the DANGEROUS case: it could be a race condition where
          # another Borg process just created the directory but hasn't written
          # the id file yet. Wait and re-check before deciding it's stale.
          if [ "$found_idfile" -eq 0 ]; then
            echo "Empty lock directory at $lockpath. Waiting 5s to rule out race condition..."
            sleep 5

            # Re-check after waiting
            for idfile in "$lockpath"/*; do
              [ -e "$idfile" ] || continue
              local basename=$(basename "$idfile")
              echo "$basename" | grep -qE '^[^@]+@.+\.pid[0-9]+\.thread[0-9]+' || continue
              local lock_pid=$(echo "$basename" | grep -oP 'pid\K\d+')
              if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
                echo "After wait: lock is now held by active PID $lock_pid. Aborting."
                exit 1
              fi
            done

             # Still empty after waiting — genuinely stale
            echo "Empty lock directory at $lockpath is stale (5s elapsed, no id file appeared). Removing."
            rm -rf "$lockpath"
            return 0
          fi

          # All id files had dead PIDs — safe to remove
          echo "All lock holders are dead. Removing stale lock at $lockpath."
          rm -rf "$lockpath"
        }

        # Break repository lock
        if echo "$BORG_REPO" | grep -qE '^(ssh://|sftp://|[^/]+:)'; then
          # Remote repo: delegate to borg break-lock over SSH
          # ${pkgs.borgbackup}/bin/borg break-lock "$BORG_REPO" 2>/dev/null || true
          echo "TODO: safely call borg break-lock"
        else
          # Local repo: directly remove stale lock
          break_stale_lock "$BORG_REPO/lock.exclusive"
        fi

        # Break all cache locks
        for cachedir in /root/.cache/borg/*/lock.exclusive; do
          break_stale_lock "$cachedir"
        done'';
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
          preHook = breakStaleLock;
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
          startAt = cfg.startAt;
          extraCreateArgs = [
            "--stats"
            "--verbose"
          ];
          removableDevice = true;
          persistentTimer = true;
          preHook = breakStaleLock;
        };

        systemd.services.borgbackup-job-borgbase.serviceConfig = {
          KillSignal = "SIGINT";
          TimeoutStopSec = "30min";
          FinalKillSignal = "SIGKILL";
        };

        systemd.services.borgbackup-job-localexternal = {
          unitConfig = {
            After = cfg.localRepoMount;
            BindsTo = cfg.localRepoMount;
            ConditionPathIsDirectory = cfg.localRepo;
          };
          serviceConfig = {
            KillSignal = "SIGINT";
            TimeoutStopSec = "30min";
            FinalKillSignal = "SIGKILL";
          };
          wantedBy = [ cfg.localRepoMount ];
        };

        systemd.timers.borgbackup-job-localexternal = {
          unitConfig = {
            After = cfg.localRepoMount;
            BindsTo = cfg.localRepoMount;
          };
          wantedBy = [ cfg.localRepoMount ];
        };
      };
    };
}

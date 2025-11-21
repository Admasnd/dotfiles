{
  den.aspects.backup.nixos =
    { lib, ... }:
    {
      services.borgbackup.jobs.borgbase = {
        paths = "/home/antwane";
        exclude = [
          "*/Downloads"
          "*/result"
          "*/target"
        ];
        doInit = false;
        encryption = {
          mode = "repokey-blake2";
          passCommand = lib.mkDefault "cat path";
        };
        environment.BORG_RSH = "ssh -i /home/antwane/.ssh/id_borgbase";
        repo = lib.mkDefault "repo";
        persistentTimer = true;
        inhibitsSleep = true;
        startAt = "hourly";
        extraCreateArgs = [
          "--stats"
          "--verbose"
        ];
      };
      services.borgbackup.jobs.localexternal = {
        paths = "/home/antwane";
        exclude = [
          "*/Downloads"
          "*/result"
          "*/target"
        ];
        doInit = false;
        encryption = {
          mode = "repokey-blake2";
          passCommand = lib.mkDefault "cat path";
        };
        repo = "/run/media/antwane/FRAME-USB/borg";
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
          After = "run-media-antwane-FRAME\\x2dUSB.mount";
          BindsTo = "run-media-antwane-FRAME\\x2dUSB.mount";
          ConditionPathIsDirectory = "/run/media/antwane/FRAME-USB/borg";
        };
        wantedBy = [ "run-media-antwane-FRAME\\x2dUSB.mount" ];
      };

      systemd.timers.borgbackup-job-localexternal = {
        unitConfig = {
          After = "run-media-antwane-FRAME\\x2dUSB.mount";
          BindsTo = "run-media-antwane-FRAME\\x2dUSB.mount";
        };
        wantedBy = [ "run-media-antwane-FRAME\\x2dUSB.mount" ];
        timerConfig.OnUnitActiveSec = "1h";
      };
    };
}

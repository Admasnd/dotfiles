{
  flake.modules.nixos.power =
    { pkgs, ... }:
    {
      boot.resumeDevice = "/dev/mapper/crypted";

      boot.kernelParams = [
        "resume=/dev/mapper/crypted"
        "resume_offset=533760"
        "mem_sleep_default=deep" # use low-leakage S3
      ];

      systemd.sleep.extraConfig = ''
        # Give the laptop 60 min in S3, then hibernate
        HibernateDelaySec=3600
      '';

      services.logind = {
        settings.Login = {
          # Lid closed while on battery  ➜  suspend-then-hibernate
          HandleLidSwitch = "suspend-then-hibernate";
          # Lid closed while on AC      ➜  do nothing
          HandleLidSwitchExternalPower = "ignore";
          HandlePowerKey = "suspend-then-hibernate";
          HandlePowerKeyLongPress = "poweroff";
          IdleActionSec = 1800;
          IdleAction = "suspend-then-hibernate";
        };
      };

      services.desktopManager.gnome.extraGSettingsOverrides = ''
        [org.gnome.settings-daemon.plugins.power]
        sleep-inactive-ac-type='nothing'
        sleep-inactive-battery-type='nothing'
        sleep-inactive-battery-timeout=0
        sleep-inactive-ac-timeout=0
      '';

      powerManagement = {
        enable = true;
        powertop.enable = true;
      };

      # Tag AC online/offline events so systemd can react
      services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ATTR{type}=="Mains", \
            RUN+="${pkgs.systemd}/bin/systemctl start ac-event@$attr{online}.service"
      '';

      # busctl
      systemd.services."ac-event@" = {
        description = "Handle AC plug/unplug events (arg = 0/1)";
        # One instance per event value (0 = on battery, 1 = on AC)
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            let
              ac-event = pkgs.writeShellApplication {
                name = "ac-event";
                runtimeInputs = with pkgs; [
                  logger
                  systemd
                  power-profiles-daemon
                ];
                text = builtins.readFile ./ac-handler.sh;
              };
            in
            "${ac-event}/bin/ac-event %i";
          KillMode = "process";
        };
        restartIfChanged = false;
      };
    };
}

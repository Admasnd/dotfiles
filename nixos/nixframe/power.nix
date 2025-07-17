{pkgs, ...}: let
  controller = pkgs.writeShellApplication {
    name = "fw-charge-controller";
    runtimeInputs = [pkgs.fw-ectool];
    text = ''
      CAP=$(cat /sys/class/power_supply/BAT1/capacity)
      if [ "$CAP" -ge 80 ]; then
         ectool chargecontrol idle
      else
         ectool chargecontrol normal
      fi
    '';
  };
in {
  # prevent overheating
  services.thermald.enable = true;

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=60min
    MemorySleepMode=deep
  '';

  services.logind.lidSwitch = "suspend-then-hibernate";

  services.tlp = {
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
    };
  };

  boot.kernelParams = [
    "mem_sleep_default=deep" # use low-leakage S3
    "intel_idle.max_cstate=9" # let cores reach deepest C-state
    "pcie_aspm.policy=powersupersave"
  ];

  services.logind.extraConfig = ''
    HandleSuspendKey=suspend-then-hibernate
    HandleLidSwitch=suspend-then-hibernate
  '';

  powerManagement.powertop.enable = true;

  # controller service
  systemd.services.fw-charge-controller = {
    description = "Framework charge controller";
    script = "${controller}/bin/fw-charge-controller";
  };

  # run every 5 min
  systemd.timers.fw-charge-controller = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
    };
  };

  systemd.services.conditional-hibernate = {
    description = "Conditional hibernate based on AC power";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "conditional-hibernate" ''
        if [ -f /sys/class/power_supply/AC*/online ]; then
            AC_ONLINE=$(cat /sys/class/power_supply/AC*/online)
            if [ "$AC_ONLINE" == '1' ]; then
                echo "On AC power, skipping hibernation"
                exit 0
            fi
        fi
        # If not on AC power, proceed with hibernation
        ${pkgs.systemd}/bin/systemctl hibernate
      '';
    };
  };

  # Override default hibernation with conditional logic
  systemd.services.systemd-hibernate.serviceConfig.ExecStart = [
    "${pkgs.systemd}/bin/systemctl start conditional-hibernate"
  ];
}

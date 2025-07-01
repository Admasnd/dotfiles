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
  '';

  services.logind.lidSwitch = "suspend-then-hibernate";

  services.tlp = {
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "performance";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };

  boot.kernelParams = [
    "mem_sleep_default=deep" # use low-leakage S3
    "intel_idle.max_cstate=9" # let cores reach deepest C-state
    "pcie_aspm.policy=powersupersave"
  ];

  services.logind.extraConfig = ''
    [Sleep]
    SuspendState=deep
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
}

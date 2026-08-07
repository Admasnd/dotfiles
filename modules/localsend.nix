{
    flake.nixosModules.laptop = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            localsend
        ];

        networking.firewall.interfaces."wlp1s0".allowedUDPPorts = [ 53317 ];
        networking.firewall.interfaces."wlp1s0".allowedTCPPorts = [ 53317 ];
    };
}

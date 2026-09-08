{
  flake.nixosModules.laptop = { pkgs, ...}:{
     services.ipp-usb.enable = true;

     services.printing = {
      enable = true;
      drivers = [
        pkgs.samsung-unified-linux-driver
        pkgs.brlaser
        (pkgs.writeTextDir "share/cups/model/brother_mfcl3780cdw_printer_en.ppd"
          (builtins.readFile ./brother_mfcl3780cdw_printer_en.ppd))
      ];
    };
  };
}

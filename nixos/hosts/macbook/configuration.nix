{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works well)
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = [ "modesetting" ];

  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ../../pkgs/hid-apple-patched.nix { })
    config.boot.kernelPackages.broadcom_sta
  ];
  boot.kernelModules = [
    "hid-apple"
    "wl"
  ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2 swap_fn_leftctrl=1 swap_opt_cmd=1
  '';

  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.67"
  ];
}

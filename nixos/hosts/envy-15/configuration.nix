{
  pkgs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "usbcore.autosuspend=-1"
  ];

  services.udev.extraRules = ''
    # Keep USB devices powered; avoid runtime suspend.
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "btop-rocm" ''
      exec ${pkgs.btop-rocm}/bin/btop "$@"
    '')
    rocmPackages.rocminfo
    amdgpu_top
  ];
}

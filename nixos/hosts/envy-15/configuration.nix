{
  pkgs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "usbcore.autosuspend=-1"
    "iommu=pt"
  ];

  services.udev.extraRules = ''
    # Keep USB devices powered; avoid runtime suspend.
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Game streaming host for Moonlight.
  # openFirewall: TCP 47984/47989/47990/48010, UDP 47998-48000/48002/48010
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true; # needed for DRM/KMS capture on Wayland
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "btop-rocm" ''
      exec ${pkgs.btop-rocm}/bin/btop "$@"
    '')
    rocmPackages.rocminfo
    amdgpu_top
  ];
}

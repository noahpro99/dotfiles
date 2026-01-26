{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "usbcore.autosuspend=-1"
    "iommu=soft"
  ];

  boot.extraModulePackages = [
    (inputs.usb-driver.makePackage config.boot.kernelPackages.kernel)
  ];
  boot.kernelModules = [ "synaptics_prometheus" ];

  services.udev.extraRules = ''
    # Keep USB devices powered; avoid runtime suspend.
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"

    # Allow users in 'input' group and the current logged-in user to access the prometheus fingerprint sensor
    SUBSYSTEM=="usbmisc", KERNEL=="prometheus*", MODE="0660", GROUP="input", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="06cb", ATTRS{idProduct}=="00c9", MODE="0660", GROUP="input", TAG+="uaccess"
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

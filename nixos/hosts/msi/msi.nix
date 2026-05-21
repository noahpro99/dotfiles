{
  config,
  pkgs,
  ...
}:
{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva
      libva-utils
      vulkan-loader
      vulkan-validation-layers
    ];
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # MSI embedded controller kernel module for fan control and other features
    extraModulePackages = [ config.boot.kernelPackages.msi-ec ];
    kernelModules = [ "msi-ec" ];
  };

  # MSI Center replacement for Linux
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "btop-cuda" ''
      exec ${pkgs.btop-cuda}/bin/btop "$@"
    '')
    android-tools # adb for quest sideloading
    opencomposite # translates SteamVR/OpenVR games to OpenXR
  ];

  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Force NVIDIA GLX
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };

  # Quest USB — allow user access for ADB
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="2833", MODE="0666", GROUP="plugdev"
  '';

  # WiVRn — streams VR to Quest over WiFi, replaces SteamVR + ALVR
  services.wivrn = {
    enable = true;
    openFirewall = true;
    package = pkgs.wivrn.override { cudaSupport = true; }; # NVIDIA hardware encoding
    highPriority = true;
  };

  security.pam.loginLimits = [
    { domain = "noahpro"; type = "-"; item = "nice"; value = "-20"; }
    { domain = "noahpro"; type = "-"; item = "rtprio"; value = "99"; }
  ];
}

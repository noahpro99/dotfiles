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
      nv-codec-headers-12
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
    # Discrete GPU only - no hybrid graphics
    prime.offload.enable = false;
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
  ];

  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Force NVIDIA GLX
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };
}

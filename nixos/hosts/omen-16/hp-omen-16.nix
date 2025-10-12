{
  config,
  pkgs,
  ...
}:
let
  hp-wmi-module = pkgs.callPackage ./hp-wmi-module.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      mesa
      nvidia-vaapi-driver
      nv-codec-headers-12
      vulkan-loader
      vulkan-validation-layers
    ];
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    dynamicBoost.enable = true;
    prime = {
      reverseSync.enable = false;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      sync.enable = false;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32GB in MB
    }
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [
      (hp-wmi-module.overrideAttrs (_: {
        patches = [ ./hp-wmi-omen-16wf-patch1.patch ];
      }))
    ];
    kernelParams = [
      "resume_offset=220098560"
      "mem_sleep_default=deep"
    ];
    resumeDevice = "/dev/disk/by-uuid/3578c20b-4858-4d22-8a98-e1620c2e54ad";
  };

  programs.omenix.enable = true;

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "btop-cuda" ''
      exec ${pkgs.btop-cuda}/bin/btop "$@"
    '')
  ];

  environment.sessionVariables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Force NVIDIA GLX
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    powerKey = "hibernate";
    powerKeyLongPress = "poweroff";
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
}

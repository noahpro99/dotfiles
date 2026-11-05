{
  config,
  lib,
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
    powerManagement.enable = true;
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
    # Was pinned to linuxPackages_6_12 while debugging wifi throughput. That pin
    # is suspected of causing it: iwlwifi in 6.12 logs "capa flags index 4 larger
    # than supported by driver" against the current linux-firmware ucode (89.x),
    # alongside "Queue 1 is stuck" and "missed beacons exceeds threshold ...
    # Expect bugs". Download over wifi sat at ~45Mb/s while a phone tethered from
    # the same spot, through the same AP, pulled 325Mb/s.
    kernelPackages = pkgs.linuxPackages_latest;
    # MSI embedded controller kernel module for fan control and other features
    extraModulePackages = [ config.boot.kernelPackages.msi-ec ];
    kernelModules = [ "msi-ec" ];

    # Wifi regulatory domain was unset (country 00), capping txpower and
    # forcing passive scan on all bands.
    #
    # power_scheme=1 is CAM (continuously awake). iwlmvm's default of 2
    # ("balanced") was parking the radio between beacons: the link negotiated
    # 960Mb/s HE80 at -55dBm with zero missed beacons, yet delivered only
    # ~50Mb/s with 37ms ping mdev and 191ms spikes. A USB tether over the same
    # uplink held 2ms mdev, which is what ruled out the AP and the ISP.
    extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom=US
      options iwlmvm power_scheme=1
    '';
  };

  # Overrides the global `wifi.powersave = true` in ../../configuration.nix.
  # NetworkManager's PSM is the other half of the throughput cap above; the
  # modprobe option alone is not enough because NM re-enables PSM per-link on
  # activation. Forced rather than merged because the global default stays on
  # for the MacBooks, which actually run off battery.
  networking.networkmanager.wifi.powersave = lib.mkForce false;

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

  zramSwap.enable = true;
  services.earlyoom.enable = true;
}

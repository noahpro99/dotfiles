{
  pkgs,
  lib,
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

  # WebGPU: Chromium only hands out the real (RADV) adapter with its Vulkan
  # feature on; without it requestAdapter() is null. Vulkan alone leaves ANGLE
  # on GL while viz composites with Vulkan, and every <video> renders solid
  # white; DefaultANGLEVulkan + VulkanFromANGLE put both on one Vulkan device,
  # which fixes that. Wrapped here rather than via chromium.override
  # { commandLineArgs }, because the nixpkgs wrapper puts those before
  # NIXOS_OZONE_WL's own --enable-features and the last one wins.
  # hiPrio so it shadows the plain chromium from user.nix; not an overlay,
  # since electron needs pkgs.chromium.override.
  users.users.noahpro.packages = [
    (lib.hiPrio (
      pkgs.symlinkJoin {
        name = "chromium-vulkan-${pkgs.chromium.version}";
        paths = [ pkgs.chromium ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/chromium \
            --add-flags "--enable-features=WaylandWindowDecorations,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
          ln -sf chromium $out/bin/chromium-browser
        '';
      }
    ))
  ];

  # Game streaming host for Moonlight. Start/stop by hand:
  #   systemctl --user start|stop sunshine
  # openFirewall: TCP 47984/47989/47990/48010, UDP 47998-48000/48002/48010
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true; # needed for DRM/KMS capture on Wayland
    autoStart = false;
  };

  # Let others ssh in (TCP 22).
  services.openssh = {
    enable = true;
    openFirewall = true;
  };
  users.users.noahpro.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEobXYd0/YXiQNG9gHfg2cXAq/6EzeDfRHos2oP7friN msi-noah"
  ];

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "btop-rocm" ''
      exec ${pkgs.btop-rocm}/bin/btop "$@"
    '')
    rocmPackages.rocminfo
    amdgpu_top
  ];
}

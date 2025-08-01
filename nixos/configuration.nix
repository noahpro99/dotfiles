# cd ~/dotfiles/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#nixos --upgrade-all
# sudo nix-collect-garbage -d

{ inputs, config, ... }:
let
  # sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
  # sudo nix-channel --update
  _stable = import inputs.nixos-stable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
    overlays = [ ];
  };
  pkgs = import inputs.nixos-unstable {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
    overlays = [ ];
  };
  hp-wmi-module = pkgs.callPackage /home/noahpro/repos/kernel-dev/source/hp-wmi-module.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
      mesa
      nvidia-vaapi-driver
      nv-codec-headers-12
    ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    dynamicBoost.enable = true;
    prime = {
      reverseSync.enable = true;
      offload = {
        enable = false;
        enableOffloadCmd = true;
      };
      sync.enable = false;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_testing;
    extraModulePackages = [
      (hp-wmi-module.overrideAttrs (_: {
        patches = [ /home/noahpro/repos/kernel-dev/patches/hp-wmi-omen-16wf-patch1.patch ];
      }))
    ];
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.noahpro = {
    isNormalUser = true;
    description = "Noah Provenzano";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
    # for user only packages
    packages = with pkgs; [
      zoom-us
      vlc
      vesktop
      discord
      lunar-client
      obs-studio
      heroic # epic games
      steam
      protonup-qt # adds proton-ge to fix some games
      protontricks
      prisma-engines
      python310
      texliveTeTeX
      pandoc
      gnupg
      pinentry-tty # for gpg
      protobuf
      btop-rocm
      ghostty
      r2modman
      godot
    ];
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true;

  programs = {
    bash = {
      interactiveShellInit = ''
        eval "$(direnv hook bash)"
      '';
    };
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    hyprlock.enable = true;
    waybar.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ libuuid.lib alsa-lib glibc libgcc.lib ];
    };
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    google-chrome

    # code
    vscode
    git
    pass
    stow
    fzf
    zoxide
    gcc
    direnv
    libgcc
    eza
    gh
    bun
    nodejs_20
    nil
    nixpkgs-fmt
    starship
    rustup
    htop
    python312
    ffmpeg
    uv
    zip
    unzip
    sea-orm-cli
    openssl
    pkg-config

    # hyprland
    hyprpaper # wallpaper manager
    killall
    tofi # app launcher
    hypridle
    kdePackages.dolphin
    xdg-utils # this is needed to allow links to be opened in the browser
    dunst # notification daemon
    brightnessctl
    pamixer
    hyprsunset
    wl-clipboard
    cliphist
    grim # recommended for xdg-desktop-portal-hyprland
    slurp # recommended for xdg-desktop-portal-hyprland
    grimblast # screenshot tool
    playerctl # media keys
    networkmanagerapplet
    dotool # automate typing in wayland for nerd-dictation
    bibata-cursors # only for xcursors as fallback for hyprcursor on apps like gtk
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Enable Wayland for Hyprland
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Force NVIDIA GLX
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
  };
  environment.stub-ld.enable = true;
  virtualisation.docker.enable = true;

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services =
    {
      openssh.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };
      pcscd.enable = true;
      blueman.enable = true;
      upower.enable = true;

      power-profiles-daemon.enable = true;

      keyd = {
        enable = true;
        keyboards = {
          default = {
            ids = [ "*" ];
            settings = {
              main = {
                capslock = "overload(control, esc)";
                esc = "capslock";
              };
              meta = {
                up = "pageup";
                down = "pagedown";
                left = "home";
                right = "end";
              };
            };
          };
        };
      };

      xserver = {
        xkb = {
          layout = "us";
          variant = "";
        };
      };
    };



  networking.firewall.allowedTCPPorts = [ 25565 3000 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}

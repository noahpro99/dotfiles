# cd ~/dotfiles/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#nixos --upgrade-all
# sudo nix-collect-garbage -d

{
  inputs,
  config,
  pkgs,
  ...
}:
let
  stable = import inputs.nixos-stable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
    overlays = [ ];
  };
  hp-wmi-module = pkgs.callPackage ./hp-wmi-module.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
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
      vulkan-loader
      vulkan-validation-layers
    ];
  };
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
    videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
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
    kernelPackages = pkgs.linuxPackages_6_15;
    extraModulePackages = [
      (hp-wmi-module.overrideAttrs (_: {
        patches = [ ./hp-wmi-omen-16wf-patch1.patch ];
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
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
    ];
    # for user only packages
    packages = with pkgs; [
      zoom-us
      vlc
      vesktop
      discord
      stable.lunar-client
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
      btop-cuda
      ghostty
      r2modman
      godot
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true;

  programs = {
    direnv = {
      enable = true;
      silent = true;
      enableBashIntegration = true;
    };
    omenix.enable = true;
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
      libraries = with pkgs; [
        libuuid.lib
        alsa-lib
        glibc
        libgcc.lib
      ];
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
    ripgrep
    bat
    fd
    gcc
    libgcc
    eza
    gh
    bun
    nodejs_20
    nixd
    nixfmt
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
    packet # quick share to android

    # hyprland
    hyprpaper # wallpaper manager
    killall
    tofi # app launcher
    hyprpolkitagent # polkit agent
    hypridle
    kdePackages.dolphin
    xdg-utils # this is needed to allow links to be opened in the browser
    dunst # notification daemon
    brightnessctl
    pamixer
    hyprsunset
    wl-clipboard
    cliphist
    grimblast # screenshot tool
    playerctl # media keys
    networkmanagerapplet
    dotool # automate typing in wayland for nerd-dictation
    bibata-cursors # only for xcursors as fallback for hyprcursor on apps like gtk
    udiskie # for mounting drives automatically and gui
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Enable Wayland for Hyprland
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Force NVIDIA GLX
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };
  environment.stub-ld.enable = true;
  virtualisation.docker.enable = true;

  powerManagement = {
    enable = true;
    powertop.enable = false; # disable since we use power-profiles-daemon
  };

  services = {
    flatpak.enable = true;
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
              capslock = "overloadt2(control, esc, 170)";
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
  };

  networking.firewall.allowedTCPPorts = [
    25565 # minecraft
    3000
    34835 # quickshare port
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05"; # double check before changing this value https://nixos.org/nixos/options.html
}

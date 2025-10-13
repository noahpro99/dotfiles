{ pkgs, ... }:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  nixpkgs.config.allowUnfree = true;

  programs = {
    direnv = {
      enable = true;
      silent = true;
      enableBashIntegration = true;
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
    appimage.enable = true;
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
    nixd
    nixfmt
    starship
    rustup
    htop
    btop
    ffmpeg
    uv
    zip
    unzip
    openssl
    pkg-config

    # hyprland
    hyprpaper # wallpaper manager
    killall
    tofi # app launcher
    hyprpolkitagent # polkit agent
    hypridle
    kdePackages.dolphin
    xdg-utils # this is needed to allow links to be opened in the browser
    dunst # notification daemon
    libnotify
    brightnessctl
    hyprsunset
    wl-clipboard
    cliphist
    hyprshot # screenshot tool
    playerctl # media keys
    networkmanagerapplet
    dotool # automate typing in wayland for nerd-dictation
    bibata-cursors # only for xcursors as fallback for hyprcursor on apps like gtk
    udiskie # for mounting drives automatically and gui
    pavucontrol # gui for pipewire/alsa/pulseaudio
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
  };
  environment.stub-ld.enable = true;
  virtualisation.docker.enable = true;

  powerManagement = {
    enable = true;
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

    udisks2.enable = true; # for udiskie

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

  system.stateVersion = "25.05"; # double check before changing this value https://nixos.org/nixos/options.html
}

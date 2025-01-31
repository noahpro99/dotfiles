# sudo cp ~/dotfiles/root/etc/nixos/configuration.nix /etc/nixos/configuration.nix
# sudo nixos-rebuild switch --upgrade-all
# sudo nix-collect-garbage -d


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ _, pkgs, ... }:
let
  # sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
  # sudo nix-channel --update
  unstable = import <nixos-unstable> {
    config = { allowUnfree = true; };
  };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Bootloader.
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # if you want grub instead
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.noahpro = {
    isNormalUser = true;
    description = "Noah Provenzano";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    # for user only packages
    packages = with pkgs; [
      zoom-us
      vlc
      vesktop
      unstable.lunar-client
      obs-studio
      heroic # epic games
      steam
      prisma-engines
      python310
      texliveTeTeX
      pandoc
      jetbrains.pycharm-professional
      gnupg
      pinentry-tty # for gpg
      unstable.deno
      protobuf
      btop
      rpi-imager
    ];
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true;

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    waybar.enable = true;
    xwayland.enable = true;
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
    nix-ld.enable = true;
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    google-chrome

    # code
    unstable.vscode
    unstable.zed-editor
    git
    pass
    stow
    fzf
    gcc
    libgcc
    gh
    unstable.bun
    nodejs_20
    nil
    nixpkgs-fmt
    starship
    rustup
    htop
    python312
    ffmpeg
    unstable.uv
    unzip
    sea-orm-cli
    openssl
    pkg-config

    # hyprland
    kitty
    waybar
    unstable.hyprpaper # wallpaper manager
    hyprwall # wallpaper gui
    killall
    tofi # app launcher
    dolphin # file manager
    pipewire # modern audio server
    wireplumber
    xdg-desktop-portal-hyprland
    xdg-utils # this is needed to allow links to be opened in the browser
    lxqt.lxqt-policykit # needed for polkit for sudo in gui apps
    dunst # notification daemon
    brightnessctl
    pamixer
    wlsunset # screen temperature
    wl-clipboard
    cliphist
    grimblast # screenshot tool
    playerctl # media keys
    networkmanagerapplet
    dotool # automate typing in wayland for nerd-dictation
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "CascadiaCode" ]; })
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.stub-ld.enable = true;
  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    pcscd.enable = true;
    blueman.enable = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 25565 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}

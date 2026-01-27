{
  pkgs,
  ...
}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.noahpro = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];
    packages = with pkgs; [
      btop
      eza
      starship
      zoxide
      fzf
    ];
  };
  environment.systemPackages = with pkgs; [
    wget
    pass
    stow
    git
    gh
    bat
    fd
    openssl
    bun
    nodejs_25
    ripgrep
    opencode

    # VPN + headless/browser auth helpers
    openconnect
    ocproxy
    chromium

    monero-cli
    p2pool
    xmrig
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  services.tailscale.enable = true;
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };
  networking.firewall.allowedTCPPorts = [
    25565 # default minecraft server port

    # Monero node and P2Pool ports for remote mining
    18081 # Monero RPC port
    18083 # Monero ZMQ port
    3333 # P2Pool mining port
    37889 # P2Pool peer discovery
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}

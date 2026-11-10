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
    fresh-editor
    bat
    fd
    openssl
    bun
    nodejs_24
    ripgrep
    opencode
    jq

    # VPN + headless/browser auth helpers
    openconnect
    ocproxy
    twurl
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
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}

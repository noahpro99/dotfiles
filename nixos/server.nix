{
  pkgs,
  config,
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
    jq

    # VPN + headless/browser auth helpers
    openconnect
    ocproxy
    chromium
    twurl

    monero-cli
    p2pool
    xmrig
  ];

  systemd.services.xmrig = {
    description = "XMRig Monero Miner";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xmrig}/bin/xmrig -o ${
        if config.networking.hostName == "macbook-air-b" then "127.0.0.1" else "100.99.222.43"
      }:3333 -u 44Zby4fvfieUgu1JpvR7ajfCnh5beestVg7QF6oMPH215U7DpvtByaKhUAVhEmuDmoFj56oU1Aj1jFWZpNBbt7uuNbHKd8Y --rig-id ${config.networking.hostName} --keepalive";
      Restart = "always";
      Nice = 10;
      CapabilityBoundingSet = "CAP_SYS_RAWIO";
      AmbientCapabilities = "CAP_SYS_RAWIO";
      User = "root";
    };
  };

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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}

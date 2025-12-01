{
  pkgs,
  ...
}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.hostName = "macbook-air-b";

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  services.logind = {
    settings.Login.lidSwitch = "ignore";
    settings.Login.lidSwitchDocked = "ignore";
    settings.Login.powerKey = "ignore";
    settings.Login.suspendKey = "ignore";
    settings.Login.hibernateKey = "ignore";
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

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

  virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}

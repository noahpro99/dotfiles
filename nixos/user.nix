{
  inputs,
  pkgs,
  ...
}:
let
  hostname = "noah-laptop";
  username = "noahpro";
  userDescription = "Noah Provenzano";

  stable = import inputs.nixos-stable {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
    overlays = [ ];
  };
in
{
  networking.hostName = hostname;
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

  users.users.${username} = {
    isNormalUser = true;
    description = userDescription;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
    ];
    # for user only packages
    packages = with pkgs; [
      # main
      google-chrome
      vscode

      # noah dev
      rustup
      sea-orm-cli

      # kinda spesific to me
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
      ghostty
      r2modman
      godot
      openconnect
      eclipses.eclipse-sdk
      packet # quick share to android
    ];
  };
  networking.firewall.allowedTCPPorts = [
    25565 # default minecraft server port
    34835 # quick share to android port
  ];
}

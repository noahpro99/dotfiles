{
  pkgs,
  ...
}:
let
  hostname = "noah-laptop";
  username = "noahpro";
  userDescription = "Noah Provenzano";
  timeZone = "America/New_York";
  locale = "en_US.UTF-8";
in
{
  networking.hostName = hostname;
  time.timeZone = timeZone;
  i18n.defaultLocale = locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
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

      # kinda specific to me
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
      r2modman
      godot
      openconnect
      ocproxy
      eclipses.eclipse-sdk
      packet # quick share to android
      opencode
      bluetui
      codex
    ];
  };
  virtualisation.waydroid.enable = true;

  networking.firewall.allowedTCPPorts = [
    25565 # default minecraft server port
    34835 # quick share to android port
  ];
}

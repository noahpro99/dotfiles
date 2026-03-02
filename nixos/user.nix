{
  pkgs,
  inputs,
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
      "libvirtd"
    ];
    # for user only packages
    packages = with pkgs; [
      # main
      google-chrome
      chromium
      vscode
      zoom-us
      vlc
      vesktop
      discord
      localsend

      # noah dev
      rustup
      sea-orm-cli
      opencode
      claude-code
      codex
      fresh-editor
      gitui
      github-copilot-cli
      gemini-cli

      # games
      lunar-client
      prismlauncher
      obs-studio
      heroic # epic games
      steam
      protonup-qt # adds proton-ge to fix some games
      protontricks
      r2modman

      texliveTeTeX
      pandoc
      gnupg
      pinentry-tty # for gpg
      openconnect
      ocproxy
      monero-cli
      monero-gui
      simplex-chat-desktop
      tor-browser
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.simplex-chat
    ];
  };

  programs.browserpass.enable = true;

  services.tailscale.enable = true;
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.firewall.allowedTCPPorts = [
    25565 # default minecraft server port
    34835 # quick share to android port
    53317 # localsend default
  ];
}

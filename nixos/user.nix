{
  pkgs,
  lib,
  inputs,
  settings ? import ./settings.nix,
  ...
}:
let
  username = settings.username;
  userDescription = settings.name;
in
{
  networking.hostName = lib.mkDefault settings.defaultHostname;
  time.timeZone = lib.mkDefault settings.timeZone;
  i18n.defaultLocale = settings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = settings.locale;
    LC_IDENTIFICATION = settings.locale;
    LC_MEASUREMENT = settings.locale;
    LC_MONETARY = settings.locale;
    LC_NAME = settings.locale;
    LC_NUMERIC = settings.locale;
    LC_PAPER = settings.locale;
    LC_TELEPHONE = settings.locale;
    LC_TIME = settings.locale;
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
      "kvm"
    ];
    # for user only packages
    packages = with pkgs; [
      # main
      google-chrome
      chromium
      zoom-us
      vlc
      libreoffice # writer, calc, impress, draw, base, math
      kdePackages.kdenlive # video editor
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.vectorcraft # vector illustration
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.photocraft # photo / psd editor
      easyeffects # pipewire audio effects / EQ
      vesktop
      discord
      inputs.morpheus.packages.${pkgs.stdenv.hostPlatform.system}.default
      arrpc # standalone Discord RPC server (better Linux game detection than Vesktop's built-in)
      # nixpkgs bug (1.18.0): binary needs libz.so.1 but zlib is missing from its RUNPATH
      (localsend.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          patchelf --add-rpath ${lib.makeLibraryPath [ zlib ]} $out/app/localsend/localsend_app
        '';
      }))

      # noah dev
      vscode
      zed-editor
      rustup
      sea-orm-cli
      claude-code
      codex
      fresh-editor
      gitui
      github-copilot-cli
      antigravity-ide
      antigravity-cli # provides `agy` CLI
      inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop

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

  # Run standalone arrpc so Vesktop (built-in arRPC disabled) picks up game
  # activity over localhost. Better Linux/Steam detection than the bundled one.
  systemd.user.services.arrpc = {
    description = "arRPC - Discord Rich Presence server";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.arrpc}/bin/arrpc";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  xdg.mime.defaultApplications = {
    "text/html" = "chromium-browser.desktop";
    "x-scheme-handler/http" = "chromium-browser.desktop";
    "x-scheme-handler/https" = "chromium-browser.desktop";
    "x-scheme-handler/about" = "chromium-browser.desktop";
    "x-scheme-handler/unknown" = "chromium-browser.desktop";
  };

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
    19132 # bedrock port
    34835 # quick share to android port
    53317 # localsend default
  ];
}

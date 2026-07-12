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
      "kvm"
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
      arrpc # standalone Discord RPC server (better Linux game detection than Vesktop's built-in)
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

  # "Coding in Ghostty" Discord presence while Ghostty is open. Pushes to
  # arrpc's IPC socket only when a ghostty process exists; clears on exit.
  # Requires a Discord Application named "Ghostty" with an art asset keyed
  # "ghostty" -- paste its Application ID into CLIENT_ID below.
  systemd.user.services.ghostty-presence =
    let
      ghostty-presence = pkgs.writers.writePython3Bin "ghostty-presence"
        {
          libraries = [ pkgs.python3Packages.pypresence ];
          flakeIgnore = [ "E501" "E722" ];
        } ''
        import os, time
        from pypresence import Presence

        CLIENT_ID = "PASTE_YOUR_DISCORD_APPLICATION_ID_HERE"

        def ghostty_running():
            for pid in os.listdir("/proc"):
                if not pid.isdigit():
                    continue
                try:
                    with open("/proc/%s/comm" % pid) as f:
                        if "ghostty" in f.read():
                            return True
                except OSError:
                    continue
            return False

        rpc = None
        start = None
        while True:
            try:
                if ghostty_running():
                    if rpc is None:
                        rpc = Presence(CLIENT_ID)
                        rpc.connect()
                        start = int(time.time())
                    rpc.update(details="Coding", large_image="ghostty",
                               large_text="Ghostty", start=start)
                elif rpc is not None:
                    rpc.clear()
                    rpc.close()
                    rpc = None
                    start = None
            except Exception:
                rpc = None
                start = None
            time.sleep(15)
      '';
    in
    {
      description = "Discord Rich Presence: Coding in Ghostty";
      wantedBy = [ "default.target" ];
      after = [ "arrpc.service" ];
      serviceConfig = {
        ExecStart = "${ghostty-presence}/bin/ghostty-presence";
        Restart = "on-failure";
        RestartSec = 10;
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

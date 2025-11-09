{
  pkgs,
  inputs,
  ...
}:
{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    plymouth = {
      enable = true;
      theme = "spinner";
    };
    initrd.verbose = false;
    consoleLogLevel = 3;
    kernelParams = [
      "quiet" # suppress kernel/boot messages unless a failure occurs or you press Esc
      "splash" # tell plymouth to show the splash screen during boot
      "boot.shell_on_fail" # drop to an emergency shell if initrd fails
      "udev.log_priority=3" # limit early udev logging to warnings and errors
      "rd.systemd.show_status=auto" # hide systemd status output unless boot is slow or fails
      "plymouth.ignore-serial-consoles" # avoid stalling on absent serial consoles when using plymouth
    ];
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  nixpkgs.config.allowUnfree = true;

  programs = {
    direnv = {
      enable = true;
      silent = true;
      enableBashIntegration = true;
    };
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    hyprlock.enable = true;
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
    appimage.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        libuuid.lib
        alsa-lib
        glibc
        libgcc.lib
      ];
    };
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = (
    with pkgs;
    [
      git
      pass
      stow
      fzf
      zoxide
      ripgrep
      bat
      fd
      gcc
      libgcc
      eza
      gh
      bun
      nixd
      nixfmt
      starship
      rustup
      htop
      btop
      ffmpeg
      uv
      zip
      unzip
      openssl
      pkg-config
      jq

      # hyprland
      hyprpaper # wallpaper manager
      hyprpicker # color picker
      killall
      tofi # app launcher
      hyprpolkitagent # polkit agent
      hypridle
      nautilus # file manager
      overskride # bluetooth
      xdg-utils # this is needed to allow links to be opened in the browser
      dunst # notification daemon
      libnotify
      brightnessctl
      hyprsunset
      wl-clipboard
      cliphist
      hyprshot # screenshot tool
      playerctl # media keys
      waybar
      dotool # automate typing in wayland for nerd-dictation
      bibata-cursors # only for xcursors as fallback for hyprcursor on apps like gtk
      udiskie # for mounting drives automatically and gui
      pwvucontrol # gui for pipewire
      terminaltexteffects # tte for screensaver
      ghostty
    ]
    ++ [
      inputs.tofi-emoji.packages."${pkgs.stdenv.hostPlatform.system}".tofi-emoji
      inputs.aether.packages."${pkgs.stdenv.hostPlatform.system}".default
    ]
  );

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Enable Wayland for Hyprland
  };
  environment.stub-ld.enable = true;
  virtualisation.docker.enable = true;

  powerManagement = {
    enable = true;
  };

  services = {
    flatpak.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    pcscd.enable = true;
    upower.enable = true;

    udisks2.enable = true; # for udiskie

    power-profiles-daemon.enable = true;

    displayManager.ly = {
      enable = true;
      settings = {
        hideusers = false;
        "session-order" = "hyprland";
        "show-sessions" = false;
        "show-users" = true;

        full_color = true;
        bg = "0x20000000"; # background animation base (black)
        fg = "0x00FAFAFA"; # white text
        border_fg = "0x004E4643"; # dark gray border (#4e4643)
        error_fg = "0x00FA824C"; # orange highlight (#fa824c)

        blank_box = true; # solid background inside login box
        box_bg = "0x00000000"; # pure black
        hide_borders = false;
        hide_key_hints = true;
        hide_version_string = true;

        animation = "colormix";
        colormix_col1 = "0x004E4643"; # gray
        colormix_col2 = "0x00FA824C"; # orange
        colormix_col3 = "0x20000000"; # black base

        asterisk = "0x2022"; # • bullet
        input_len = 34;
        save = true;
      };
    };

    keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            main = {
              capslock = "overloadt2(control, esc, 170)";
              esc = "capslock";
            };
            meta = {
              up = "pageup";
              down = "pagedown";
              left = "home";
              right = "end";
            };
          };
        };
      };
    };
  };

  system.stateVersion = "25.05"; # double check before changing this value https://nixos.org/nixos/options.html
}

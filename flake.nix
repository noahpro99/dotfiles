{
  nixConfig.experimental-features = [
    "nix-command"
    "flakes"
  ];
  description = "Noah's dotfiles and reusable NixOS modules";

  inputs = {
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    omenix.url = "github:noahpro99/omenix";
    omenix.inputs.nixpkgs.follows = "nixos-unstable";
    tofi-emoji.url = "github:noahpro99/tofi-emoji";
    tofi-emoji.inputs.nixpkgs.follows = "nixos-unstable";
    aether.url = "github:noahpro99/aether/flake-v3";
    aether.inputs.nixpkgs.follows = "nixos-unstable";
    hyprland-preview-share-picker.url = "git+https://github.com/WhySoBad/hyprland-preview-share-picker?submodules=1";
    hyprland-preview-share-picker.inputs.nixpkgs.follows = "nixos-unstable";
    flyline.url = "github:HalFrgrd/flyline";
    flyline.inputs.nixpkgs.follows = "nixos-unstable";
    claude-desktop.url = "github:poeck/claude-desktop-nix-flake";
    claude-desktop.inputs.nixpkgs.follows = "nixos-unstable";
  };

  outputs =
    {
      self,
      nixos-unstable,
      omenix,
      tofi-emoji,
      aether,
      hyprland-preview-share-picker,
      ...
    }@inputs:
    let
      # Reusable builder for desktop / laptop hosts
      mkHost =
        extraModules:
        nixos-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/configuration.nix
            ./nixos/user.nix
          ]
          ++ extraModules;
        };

      # Reusable builder for headless server hosts
      mkServerHost =
        hostName: extraModules:
        nixos-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/server.nix
            ./nixos/hosts/macbook/configuration.nix
            ./nixos/hosts/macbook/server.nix
            { networking.hostName = hostName; }
          ]
          ++ extraModules;
        };
    in
    {
      # Reusable modules for other flakes
      nixosModules = {
        default = import ./nixos/configuration.nix;
        omen-16 = import ./nixos/hosts/omen-16/hp-omen-16.nix;
        msi = import ./nixos/hosts/msi/msi.nix;
      };

      packages.x86_64-linux = {
        simplex-chat = import ./nixos/pkgs/simplex-chat.nix {
          pkgs = nixos-unstable.legacyPackages.x86_64-linux;
        };
        vectorcraft = import ./nixos/pkgs/vectorcraft.nix {
          pkgs = nixos-unstable.legacyPackages.x86_64-linux;
        };
        photocraft = import ./nixos/pkgs/photocraft.nix {
          pkgs = nixos-unstable.legacyPackages.x86_64-linux;
        };
      };

      nixosConfigurations = {
        omen-16 = mkHost [
          ./nixos/hosts/omen-16/hardware-configuration.nix
          ./nixos/hosts/omen-16/hp-omen-16.nix
          inputs.omenix.nixosModules.default
        ];

        envy-15 = mkHost [
          ./nixos/hosts/envy-15/configuration.nix
        ];

        msi = mkHost [
          ./nixos/hosts/msi/hardware-configuration.nix
          ./nixos/hosts/msi/msi.nix
        ];

        macbook-air-a = mkServerHost "macbook-air-a" [
          ./nixos/hosts/macbook/macbook-air-a/hardware-configuration.nix
          ./nixos/hosts/macbook/macbook-air-a/configuration.nix
          (
            { pkgs, ... }:
            {
              environment.systemPackages = [
                inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.simplex-chat
              ];
            }
          )
        ];

        macbook-air-b = mkServerHost "macbook-air-b" [
          ./nixos/hosts/macbook/macbook-air-b/hardware-configuration.nix
          ./nixos/hosts/macbook/macbook-air-b/configuration.nix
          {
            swapDevices = [
              {
                device = "/swapfile";
                size = 8192;
              }
            ];
          }
        ];
      };
    };
}

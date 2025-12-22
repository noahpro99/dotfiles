{
  nixConfig.experimental-features = [
    "nix-command"
    "flakes"
  ];
  description = "Noah's dotfiles and reusable NixOS modules";

  inputs = {
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    omenix.url = "github:noahpro99/omenix";
    tofi-emoji.url = "github:noahpro99/tofi-emoji";
    aether.url = "github:noahpro99/aether/nixos";
  };

  outputs =
    {
      self,
      nixos-stable,
      nixos-unstable,
      omenix,
      tofi-emoji,
      aether,
      ...
    }@inputs:
    {
      # Reusable modules for other flakes
      nixosModules = {
        default = import ./nixos/configuration.nix;
        omen-16 = import ./nixos/hosts/omen-16/hp-omen-16.nix;
      };

      nixosConfigurations.omen-16 = nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          ./nixos/user.nix
          ./nixos/hosts/omen-16/hardware-configuration.nix
          ./nixos/hosts/omen-16/hp-omen-16.nix
          inputs.omenix.nixosModules.default
        ];
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations.envy-15 = nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          ./nixos/user.nix
          ./nixos/hosts/envy-15/configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations.macbook-air-a = nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/server.nix
          ./nixos/hosts/macbook/configuration.nix
          ./nixos/hosts/macbook/server.nix
          ./nixos/hosts/macbook/macbook-air-a/hardware-configuration.nix
          { networking.hostName = "macbook-air-a"; }
        ];
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations.macbook-air-b = nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/server.nix
          ./nixos/hosts/macbook/configuration.nix
          ./nixos/hosts/macbook/server.nix
          ./nixos/hosts/macbook/macbook-air-b/hardware-configuration.nix
          { networking.hostName = "macbook-air-b"; }
        ];
        specialArgs = { inherit inputs; };
      };
    };
}

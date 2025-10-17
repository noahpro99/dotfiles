{
  description = "Noah's dotfiles and reusable NixOS modules";

  inputs = {
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    omenix.url = "github:noahpro99/omenix";
    tofi-emoji.url = "github:noahpro99/tofi-emoji";
  };

  outputs =
    {
      self,
      nixos-stable,
      nixos-unstable,
      omenix,
      tofi-emoji,
      ...
    }@inputs:
    {
      # Reusable modules for other flakes
      nixosModules = {
        default = import ./nixos/configuration.nix;
        omen-16 = import ./nixos/hosts/omen-16/hp-omen-16.nix;
      };

      # Personal host (relies on /etc hardware config)
      nixosConfigurations.nixos = nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          ./nixos/user.nix
          /etc/nixos/hardware-configuration.nix
          ./nixos/hosts/omen-16/hp-omen-16.nix
          inputs.omenix.nixosModules.default
        ];
        specialArgs = { inherit inputs; };
      };
    };
}

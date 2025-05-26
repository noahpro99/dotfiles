{
  inputs = {
    nixos-stable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixos-stable, nixos-unstable, ... }@inputs: {
    nixosConfigurations.nixos = nixos-stable.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
      specialArgs = { inherit inputs; };
    };
  };
}

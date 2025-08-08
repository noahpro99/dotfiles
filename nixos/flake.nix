{
  inputs = {
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    omenix.url = "github:Hiten-Tandon/omenix";
  };

  outputs =
    {
      self,
      nixos-stable,
      nixos-unstable,
      omenix,
    }@inputs:
    {
      nixosConfigurations.nixos = nixos-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
}

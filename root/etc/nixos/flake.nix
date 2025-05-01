{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
  };

  outputs = { self, nixpkgs, nixos-unstable, hyprpanel, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
      specialArgs = { inherit inputs; };
    };
  };
}

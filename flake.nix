{
  description = "Nurrrr >^^<: Name's Nix user repository";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-darwin"
        "aarch64-darwin"
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
    in
    {
      # Creates a package set over the packages provided in default.nix
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );

      # Attr's over the legacyPackages, providing only the derivations
      # This is done for every system. This isn't an issue though since compatibility is
      # Defined by meta.platforms.
      # Maybe in future it'll change
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      # Offer a flake way to use nixosModules
      nixosModules.default = import ./modules/nixos { nurrrr = self; };
    };
}

{
  # Fallback to the system Nixpkgs for classic compat
  pkgs ? import <nixpkgs> { },
}:
{
  # lib = import ./lib { inherit pkgs; };
  modules = import ./modules; # Classic way of handling modules
  # overlays = import ./overlays;

  # We define packages here by calling the package
  ddnsh = pkgs.callPackage ./pkgs/ddnsh.nix { };
  # rose = pkgs.callPackage ./pkgs/rose.nix {};
}

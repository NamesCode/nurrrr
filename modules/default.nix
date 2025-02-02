{ nurrrr }:
{ pkgs }:
{
  nixos = import ./nixos { nurrrr-pkgs = nurrrr.legacyPackages.${pkgs.stdenv.hostPlatform.system}; };
}

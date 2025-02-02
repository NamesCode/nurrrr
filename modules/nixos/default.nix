{ nurrrr }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  niceImport =
    file:
    (import file {
      inherit lib config pkgs;
      nurrrr-pkgs = nurrrr.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    });
in
{
  imports = [
    (niceImport ./ddnsh.nix)
  ];
}

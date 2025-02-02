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
      inherit
        lib
        config
        pkgs
        nurrrr
        ;
    });
in
{
  nixos = niceImport ./nixos;
}

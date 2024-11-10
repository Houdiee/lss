{ pkgs ? import <nixpkgs> {} }:

let
  nimblePackages = [
    "nancy"
    "termstyle"
  ];
in
pkgs.mkShell {
  buildInputs = [
    pkgs.nimble
  ];

  shellHook = ''
    for package in ${builtins.concatStringsSep " " nimblePackages}; do
      nimble install $package
    done
  '';
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils = { url = "github:numtide/flake-utils"; };
    custom = {
      url = "github:puyral/custom-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, utils, custom, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        src = ./.;
        custom-pkgs = custom.packages.${system};
      in {
        formatter = nixpkgs.legacyPackages.${system}.nixfmt;
        devShell = pkgs.mkShell { buildInputs = with pkgs; [ nixd python3 ] ++ lib.optional stdenv.isDarwin git; };
      });
}

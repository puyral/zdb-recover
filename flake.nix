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
        formatter = pkgs.nixfmt;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs;
            [ python3 ] ++ lib.optional stdenv.isDarwin git;
          shellHook = ''
            echo "make sure 'zdb' is available"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zdb-recover";
          version = "0.1.1";

          src = src;

          buildInputs = with pkgs; [ python3 ];

          installPhase = ''
            mkdir -p $out/bin
            # Create a wrapper to execute the script with python
            echo '#!/usr/bin/env bash' > $out/bin/zdb-recover
            echo "exec ${pkgs.python3}/bin/python ${src}/zdb_recover.py \"\$@\"" >> $out/bin/zdb-recover
            chmod +x $out/bin/zdb-recover
          '';

          # todo
          # meta = with pkgs.lib; {
          #   description = "A Python script for recovering ZFS data using zdb.";
          #   license = licenses.mit; # Replace with your script's license
          #   maintainers = with maintainers;
          #     [ puyral ]; # Replace with your GitHub handle
          # };
        };
      });
}

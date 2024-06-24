{
  description = "A super boring flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    foundry = {
      url = "github:shazow/foundry.nix/monthly";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    solc = {
      url = "github:hellwolf/solc.nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mk-cache-key = {
      url = "github:hellwolf/mk-cache-key.nix/master";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      foundry,
      solc,
      mk-cache-key,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        solcVer = "solc_0_8_23";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            foundry.overlay
            solc.overlay
          ];
        };
      in
      {
        # ci & local development shells
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            jq
            yq
            lcov
            bun
            foundry-bin
            pkgs.${solcVer}
            (solc.mkDefault pkgs pkgs.${solcVer})
          ];
        };

        devShells.mk-cache-key = pkgs.mkShell {
          buildInputs = [ mk-cache-key.packages.${system}.default ];
        };
      }
    );
}

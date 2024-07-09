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
      url = "github:hellwolf/mk-cache-key.nix";
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
        solhint = with pkgs; buildNpmPackage rec {
          pname = "solhint";
          version = "5.0.1";
          src = fetchFromGitHub {
            owner = "protofire";
            repo = "solhint";
            rev = "v${version}";
            hash = "sha256-7lfZGWivJi+E9IMHKA+Cu1215RaMXfFiXZ9nihvIqBU=";
          };
          npmDepsHash = "sha256-dNweOrXTS5lmnj7odCZsChysSYrWYRIPHk4KO1HVTG4=";
          dontNpmBuild = true;
        };
        mk-cache-key-pkg = mk-cache-key.packages.${system}.default;
      in
      {
        # ci & local development shells
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            mk-cache-key-pkg
            jq
            yq
            solhint
            lcov
            bun
            foundry-bin
            pkgs.${solcVer}
            (solc.mkDefault pkgs pkgs.${solcVer})
          ];
          shellHook = ''
            export FOUNDRY_OFFLINE=true;
            export FOUNDRY_SOLC_VERSION=${pkgs.lib.getExe pkgs.${solcVer}};
          '';
        };

        devShells.mk-cache-key = pkgs.mkShell {
          buildInputs = [ mk-cache-key-pkg ];
        };
      }
    );
}

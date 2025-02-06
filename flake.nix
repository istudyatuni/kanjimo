{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        devShells.python = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            (python3.withPackages (pypkgs: with pypkgs; [cbor2]))

            just
            ruff
          ];
        };

        formatter = pkgs.alejandra;
      }
    );
}

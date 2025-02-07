{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";

    tytanic = {
      url = "github:tingerrr/tytanic/v0.1.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    tytanic,
    ...
  } @ inputs:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        tytanic = inputs.tytanic.packages.${system}.default;
      in {
        devShells.python = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            (python3.withPackages (pypkgs: with pypkgs; [cbor2]))

            just
            ruff
            tytanic
          ];
        };

        formatter = pkgs.alejandra;
      }
    );
}

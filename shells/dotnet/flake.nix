{
    description = ".NET Core env with sdk lastest and sdk 8";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [];
                };

                buildInputs = with pkgs; [
                    dotnet-sdk
                    dotnet-sdk_8
                ];
            in
            {
                devShells.default = pkgs.mkShell {
                    name = "net8";
                    inherit buildInputs;
                    shellHook = ''
                        echo ".NET 8 dev shell ready!"
                    '';
                };
            }
        );
}

{
    description = "NodeJS shell with npm";

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
                    nodejs
                ];
            in
            {
                devShells.default = pkgs.mkShell {
                    name = "nodejs";
                    inherit buildInputs;
                    shellHook = ''
                        npm config set prefix ~/.npm-global
                        export PATH="$HOME/.npm-global/bin:$PATH"
                        echo "NodeJS dev shell ready!"
                    '';
                };
            }
        );
}

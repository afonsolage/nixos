{
    description = "Python3 env with pip and virtual env";

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
                    python310
                    python310Packages.pip
                    python310Packages.virtualenv
                ];
            in
            {
                devShells.default = pkgs.mkShell {
                    name = "python3";
                    inherit buildInputs;
                    shellHook = ''
                        virtualenv venv
                        source venv/bin/activate
                        echo "🐍 Python3 dev shell ready!"
                    '';
                };
            }
        );
}

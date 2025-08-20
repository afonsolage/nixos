{
    description = "Bevy dev shell with Rust nightly and Wayland deps";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                tracy-overlay = final: prev: {
                  tracy-wayland = prev.tracy-wayland.overrideAttrs (oldAttrs: {
                    pname = "tracy";
                    version = "0.12.2";
                    src = prev.fetchFromGitHub {
                      owner = "wolfpld";
                      repo = "tracy";
                      rev = "v${oldAttrs.version}";
                      hash = "sha256-HofqYJT1srDJ6Y1f18h7xtAbI/Gvvz0t9f0wBNnOZK8=";
                    };
                  });
                };
                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [ tracy-overlay ];
                };

                buildInputs = with pkgs; [
                    udev
                    alsa-lib-with-plugins
                    vulkan-loader
                    wayland
                    libxkbcommon
                    tracy-wayland
                ];
            in
            {
                devShells.default = pkgs.mkShell {
                    name = "bevy";
                    nativeBuildInputs = with pkgs; [
                        autoPatchelfHook
                        pkg-config
                    ];
                    inherit buildInputs;
                    shellHook = ''
                        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath buildInputs}"
                        echo "🦀 Bevy dev shell ready!"
                    '';
                };
            }
        );
}

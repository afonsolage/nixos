{
    description = "Bevy dev shell with Rust nightly and Wayland deps";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        tracy-upgrade.url = "github:MonaMayrhofer/nixpkgs/tracy-upgrade";
    };

    outputs = { self, nixpkgs, flake-utils, tracy-upgrade }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                tracy-overlay = final: prev: {
                    tracy-wayland = tracy-upgrade.legacyPackages.${prev.system}.tracy;
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
                    stdenv.cc.cc.lib
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

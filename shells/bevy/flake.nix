{
    description = "Bevy dev shell with Rust nightly and Wayland deps";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
               pkgs = nixpkgs.legacyPackages.${system};
                buildInputs = with pkgs; [
                    udev
                    alsa-lib-with-plugins
                    vulkan-loader
                    wayland
                    libxkbcommon
                ];
            in
            {
                devShells.default = pkgs.mkShell {
                    name = "bevy";
                    nativeBuildInputs = with pkgs; [
                        pkg-config
                    ];
                    inherit buildInputs;
                    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

                    shellHook = ''echo "🦀 Bevy dev shell ready!"'';
                };
            }
        );
}

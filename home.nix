{ config, pkgs, ... }:

let
    outOfStore = config.lib.file.mkOutOfStoreSymlink;

    dotfiles = "/home/afonsolage/nixos/dotfiles";
    mkConfigDotFiles = file: {
        name = file;
        value = { source = outOfStore "${dotfiles}/${file}"; };
    };

    # List all dotfiles that should be managed by home-manager, using dotfiles folder
    dotFiles = [
        ".config/hypr"
        ".config/nvim"
        ".config/hyprpanel"
        ".config/alacritty"
    ];
in
{
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "25.05";

    home.username = "afonsolage";
    home.homeDirectory = "/home/afonsolage";

    home.file = (builtins.listToAttrs (map mkConfigDotFiles dotFiles));

    home.packages = with pkgs; [
        # Work
        telegram-desktop
        google-chrome

        # Hyprland
        hyprshot
        hyprpanel
        wofi
        yazi
        firefox

        # dev env
        git
        ripgrep
        neovim
        alacritty

        # Rust
        rustup
    ];

    programs.git = {
        enable = true;
        extraConfig = {
            user.name = "Afonso Lage";
            user.email = "lage.afonso@gmail.com";
        };
    };
}

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
        ".bashrc"
        ".config/hypr"
        ".config/nvim"
        ".config/hyprpanel"
        ".config/starship.toml"
        ".config/easyeffects"
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

    home.file = 
        (builtins.listToAttrs (map mkConfigDotFiles dotFiles))
        // # Concat operator
        {
        ".vscode" = {
            source = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode";
        };
    };

    home.packages = with pkgs; [
        # Work
        telegram-desktop
        google-chrome

        # Hyprland
        hyprshot
        hyprpanel
        yazi
        firefox
        playerctl

        # dev env
        git
        jujutsu
        ripgrep
        neovim
        starship
        clang
        mold
        gemini-cli
        hyperfine
        heaptrack

        # etc
        qalculate-qt
        easyeffects
        discord
        du-dust

        # Rust
        rustup
        vscode-extensions.vadimcn.vscode-lldb
    ];

    programs = {
        git = {
            enable = true;
            extraConfig = {
                user.name = "Afonso Lage";
                user.email = "lage.afonso@gmail.com";
            };
        };
        alacritty = {
            enable = true;
            settings = {
                terminal.shell = "${pkgs.zellij}/bin/zellij";
            };
        };
        zellij = {
            enable = true;
            settings = {
                pane_frames = false;
            };
        };
        direnv = {
            enable = true;
            nix-direnv.enable = true;
        };
        rofi = {
            enable = true;
            plugins = [ pkgs.rofi-calc ];
            modes = [ "drun" "calc" "combi" ];
        };
        eza = {
            enable = true;
        };
        bat = {
            enable = true;
        };
    };
}

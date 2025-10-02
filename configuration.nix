# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, stylix, ... }:

{
    imports =
    [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelParams = [ "amdgpu.sg_display=0" "amdgpu.runpm=0" ];


    networking.hostName = "afonso-pc"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Fortaleza";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
    };

    # Configure console keymap
    console.keyMap = "br-abnt2";

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.afonsolage = {
        isNormalUser = true;
        description = "Afonso Lage";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; []; # Those are handled by home.nix
    };

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    }; 

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        wget
        vim
        usbutils
        blueman
        wl-clipboard
        unzip
        config.boot.kernelPackages.perf
        vial
    ];

    fonts.packages = with pkgs; [
        nerd-fonts.fira-code
    ];

    programs.hyprland.enable = true;

    programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        package = pkgs.unstable.steam;
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:
    services.displayManager.autoLogin = {
        enable = true;
        user = "afonsolage";
    };
    services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
    };

    # Enable mouse wakeup (keyboard is bugged, see bellow)
    services.udev.extraRules = ''
        # When the Pixart Gaming Mouse is detected, enable its wakeup capability.
        ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="093a", ATTRS{idProduct}=="2533", ATTR{power/wakeup}="enabled"
        # Vial
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;
    
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
    
    # Workaround for Gigabyte B550 F13 bios sleep/wakeup bug
    systemd.services.biosWakeupWorkaround = {
        enable = true;
        description = "Workaround for Gigabyte B550 F13 bios sleep/wakeup bug";
        unitConfig = {
            Type = "oneshot";
        };
        serviceConfig = {
            ExecStart = "/bin/sh -c 'if grep 'GPP0' /proc/acpi/wakeup | grep -q 'enabled'; then echo 'GPP0' > /proc/acpi/wakeup; fi'";
        };
        wantedBy = [ "multi-user.target" ];
    };

    # Workaround for Redragon K55 keyboard sleep/wakeup bug
    systemd.services.k55WakeupWorkaround = {
        enable = true;
        description = "Workaround for Redragon K55 keyboard sleep/wakeup bug";
        unitConfig = {
            Type = "oneshot";
        };
        serviceConfig = {
            ExecStart = "/bin/sh -c 'if grep 'PTXH' /proc/acpi/wakeup | grep -q 'enabled'; then echo 'PTXH' > /proc/acpi/wakeup; fi'";
        };
        wantedBy = [ "multi-user.target" ];
    };

    # Fix graphics corruption after sleeping
    powerManagement.enable = true;
    services.power-profiles-daemon.enable = true;

    hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          amdvlk
        ];
    };

    

    hardware.xpadneo.enable = true;

    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General.Experimental = true;
    };

    stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    };

    fileSystems."/home/afonsolage/d" = {
        device = "/dev/nvme0n1p3";
        fsType = "ext4";
        options = [ "rw" "relatime" ];
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?

}

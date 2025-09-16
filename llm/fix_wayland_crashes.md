# Summary of Wayland Crash Troubleshooting on NixOS

## 1. Problem Description

The user was experiencing intermittent screen freezes on their NixOS system running Hyprland.
- The screen would freeze, but audio would continue to work.
- Occasionally, the session would crash and return the user to the SDDM login screen.
- The user's configuration is managed with Nix Flakes.

## 2. Initial Investigation

The investigation started by analyzing the system logs and hardware configuration.

- **`journalctl -b -p 3`:** This command revealed critical errors.
    - **Hyprland Crash:** `Process 1447 (.Hyprland-wrapp) of user 1001 dumped core.`
    - **Xwayland Crash:** `Process 1512 (Xwayland) of user 1001 dumped core.`
    - The stack traces for both crashes pointed towards the graphics stack, with mentions of `libgallium`, `pthread_kill`, and `abort`. This strongly indicated a graphics driver or compositor issue.

- **`hardware-configuration.nix`:** This file did not contain specific information about the graphics card.

- **`lspci -k | grep -A 3 -E "(VGA|3D)"`:** This command was used to identify the GPU.
    - **Result:** `07:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 22 [Radeon RX 6700/6700 XT/6750 XT / 6800M/6850M XT] (rev c0)`
    - **Kernel Driver:** The output confirmed that the `amdgpu` kernel module was correctly in use.

## 3. Hypothesis

Based on the investigation, the hypothesis was that the crashes were due to instability in the AMD graphics driver stack (specifically Mesa, the userspace driver) when running a Wayland compositor (Hyprland). Although the correct kernel driver was loaded, certain configurations can be unstable.

The proposed solution was to apply common fixes for AMD GPUs on NixOS to improve stability under Wayland.

## 4. Changes Made to `configuration.nix`

The following changes were applied to `/home/afonsolage/nixos/configuration.nix` to stabilize the system.

1.  **Added Kernel Parameter:** A kernel parameter known to help with AMD GPU stability in Wayland was added.
    ```nix
    boot.kernelParams = [ "amdgpu.sg_display=0" ];
    ```

2.  **Added AMD Vulkan Driver:** The `amdvlk` package was added to provide an alternative Vulkan driver, which can sometimes be more stable.
    ```nix
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
    };
    ```

3.  **Configuration Cleanup:** During the process, a `nixos-rebuild` command failed due to deprecated options. The configuration was cleaned up accordingly.
    - Initially, `hardware.opengl.driSupport` and `driSupport32Bit` were added, but they were found to be deprecated and were removed.
    - A subsequent rebuild showed a warning that `hardware.opengl.enable` was renamed to `hardware.graphics.enable`. The redundant `hardware.opengl` section was removed completely.

## 5. Current Status

The user has successfully rebuilt their NixOS system with the modified configuration. The system is now being monitored to see if the screen freezes and crashes are resolved. The troubleshooting can be continued from this point if the issue persists.

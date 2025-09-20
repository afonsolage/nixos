# Summary of GPU Wake-up Fix for NixOS

## 1. Problem Description

The user experienced a black screen when waking their PC from suspend.
- This issue only occurred if a game (Path of Exile 2 via Steam) was running at the time the system was suspended.
- The screen would remain black, but game audio was still audible, indicating the system was running but the display was not re-initializing.
- The system is running NixOS with the Hyprland compositor and an AMD GPU.

## 2. Investigation

The diagnosis process involved several steps to understand the system and the nature of the problem.

- **Configuration Review:**
    - **`dotfiles/.config/hypr/hyprland.conf`:** Confirmed the sleep command was `systemctl suspend`.
    - **`hardware-configuration.nix`:** Indicated an AMD CPU.
    - **`configuration.nix`:** This file was key. It showed:
        - An AMD GPU using the `amdgpu` driver.
        - An existing kernel parameter for GPU stability: `amdgpu.sg_display=0`.
        - The `amdvlk` Vulkan driver was also installed.
        - Previous workarounds for other sleep/wakeup issues were present.

- **Review of Past Troubleshooting:**
    - The file `llm/fix_wayland_crashes.md` was reviewed. It detailed a previous, more general, graphics stability issue that was addressed by adding `amdgpu.sg_display=0` and `amdvlk`.

- **Web Search:**
    - A search for `amdgpu hyprland black screen after suspend steam` confirmed this is a known issue for users with similar hardware and software stacks.
    - The most common solutions pointed towards power management settings in the `amdgpu` driver.

## 3. Hypothesis

The evidence suggested the problem was not a general crash, but a specific failure in the driver's power management logic. When suspending with the GPU under heavy load from a game, the `amdgpu` driver's Runtime Power Management (`runpm`) feature was likely failing to restore the GPU to a fully active state upon resume.

## 4. Solution Applied

Based on the hypothesis, a targeted fix was applied to the system's configuration.

- **Modified `configuration.nix`:** The kernel parameter `amdgpu.runpm=0` was added to `boot.kernelParams`.
    - This parameter disables the `amdgpu` driver's runtime power management, which is a common workaround for suspend/resume issues.
    - The final configuration line is:
      ```nix
      boot.kernelParams = [ "amdgpu.sg_display=0" "amdgpu.runpm=0" ];
      ```

## 5. Next Steps

The user was instructed to rebuild their NixOS configuration and reboot the system to activate the new kernel parameter. The final step is to test if the issue is resolved by suspending and waking the system with a game running.
# =============================================================================
# NVIDIA GPU CONFIGURATION
# =============================================================================
# NVIDIA proprietary driver configuration optimized for Wayland compositors
#
# DRIVER CHOICE:
# - Using proprietary driver (open = false) for better stability
# - Beta driver for latest Wayland improvements
#
# WAYLAND + NVIDIA CHALLENGES:
# - Hardware cursor issues → Fixed by WLR_NO_HARDWARE_CURSORS in session vars
# - GBM backend needed → Set via environment variables
# - VRR/G-Sync conflicts → Disabled via __GL_GSYNC_ALLOWED
#
# SYSTEM VS USER CONFIGURATION:
# - This file (system): Driver installation, kernel modules
# - home/wm/niri (user): Runtime environment variables, performance tuning
# =============================================================================
{ config, lib, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # KERNEL MODULE LOADING
  # ---------------------------------------------------------------------------
  # Load Nvidia DRM module early for proper Wayland support
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Enable nvidia-drm with modesetting
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  
  # ---------------------------------------------------------------------------
  # VIDEO DRIVER CONFIGURATION
  # ---------------------------------------------------------------------------
  # Tells X server and display managers to use NVIDIA drivers
  # Even though using Wayland, this is needed for proper driver initialization
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # ---------------------------------------------------------------------------
  # NVIDIA DRIVER OPTIONS
  # ---------------------------------------------------------------------------
  hardware.nvidia = {
    # Enable modesetting (REQUIRED for Wayland)
    # Allows NVIDIA driver to work with kernel mode-setting
    # Without this, Wayland compositors won't work
    modesetting.enable = true;
    
    # Enable power management
    # Helps with laptop power saving and prevents some suspend issues
    powerManagement.enable = true;
    
    # Disable fine-grained power management
    # Fine-grained can cause issues with some desktop setups
    # Set to true for laptops to improve battery life
    powerManagement.finegrained = false;
    
    # Use proprietary driver (not open-source)
    # Open-source NVIDIA driver is newer but less stable
    # Proprietary driver recommended for production use
    open = false;
    
    # Enable nvidia-settings GUI tool
    # Provides NVIDIA control panel for configuration
    # Access via: nvidia-settings
    nvidiaSettings = true;
    
    # Use stable driver for reliability
    # Options: stable, beta, production, latest
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Force full composition pipeline
    # Reduces tearing and improves Wayland performance
    # May slightly increase latency but provides smoother rendering
    forceFullCompositionPipeline = true;
  };

  # ---------------------------------------------------------------------------
  # GRAPHICS SUPPORT
  # ---------------------------------------------------------------------------
  # Enable OpenGL and Vulkan support
  hardware.graphics = {
    # Enable hardware acceleration for graphics
    enable = true;
    
    # Enable 32-bit driver support
    # Required for Steam and other 32-bit games
    # Also needed for some Wine applications
    enable32Bit = true;
  };
  
  # ---------------------------------------------------------------------------
  # ADDITIONAL NVIDIA OPTIMIZATIONS
  # ---------------------------------------------------------------------------
  # For more aggressive performance tuning, add these to user session variables
  # (already configured in home/wm/niri/default.nix):
  #
  # __GL_YIELD = "NOTHING"           # Reduce CPU usage when waiting for GPU
  # __GL_THREADED_OPTIMIZATION = 1   # Enable driver threading
  # WLR_NO_HARDWARE_CURSORS = 1      # Fix cursor rendering issues
  # LIBVA_DRIVER_NAME = "nvidia"     # Hardware video acceleration
  # GBM_BACKEND = "nvidia-drm"       # Required for Wayland
  #
  # TROUBLESHOOTING:
  # - Black screen: Check __GLX_VENDOR_LIBRARY_NAME = "nvidia"
  # - Cursor invisible: Verify WLR_NO_HARDWARE_CURSORS = 1
  # - Poor performance: Enable __GL_THREADED_OPTIMIZATION
  # - Tearing: Ensure forceFullCompositionPipeline = true
  # ---------------------------------------------------------------------------
}

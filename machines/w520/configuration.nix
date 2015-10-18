 { config, pkgs, ... }:
                
{               
    imports =   
      [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./private/password.nix
      ];
      
  # Use the gummiboot efi boot loader.
    boot.loader.gummiboot.enable = true;
    boot.loader.gummiboot.timeout = 4;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_3_19;
    boot.kernelModules = [ "kvm-intel" "iwlwifi" "iwldvm" ];

  # http://unix.stackexchange.com/questions/163012/iwlwifi-timeout-delays-firmware-to-be-loaded
     services.udev.extraRules = ''
      SUBSYSTEM=="firmware", ACTION=="add", ATTR{loading}="-1"
  '';
    
    networking.hostName = "stighenriksen-nixos"; # Define your hostname.
    networking.hostId = "eb210571";
    networking.wireless.enable = true;
    networking.wireless.interfaces = [ "wlp3s0" ];
    networking.interfaceMonitor.enable = true;
    networking.wicd.enable = true;
    
    i18n = {
      consoleFont = "lat9w-16";
        consoleKeyMap = "us";
        defaultLocale = "en_US.UTF-8";
    };  
    
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.chromium.enablePepperFlash = true;
    nixpkgs.config.chromium.enablePepperPDF = true;
      nixpkgs.config.chromium.enableWideVine = true;
    
   environment.systemPackages = with pkgs; [
     wget emacs chromium acpi xsel git haskellPackages.taffybar dmenu
     nix-repl haskellPackages.cabal2nix
   ];

     fonts = {
     enableFontDir = true;
     enableGhostscriptFonts = true;
     fonts = with pkgs; [
       corefonts  # Micrsoft free fonts
       inconsolata  # monospaced
       ubuntu_font_family  # Ubuntu fonts
     ];
   };

   programs.ssh.startAgent = true;
   
   hardware.opengl.enable = true;
   hardware.opengl.driSupport = true;
   hardware.opengl.driSupport32Bit = true;
   
    hardware.bumblebee.enable = false;
    
    services.xserver = {
        videoDrivers = [ "nvidia" ];
       enable = true;
      layout = "us";
        displayManager.desktopManagerHandlesLidAndPower = false;

        displayManager.kdm.enable = true;

        displayManager.sessionCommands = ''
         sh /home/stig/.fehbg
         ssh-add ~/.ssh/id_rsa
       '';
        
      windowManager.xmonad.enable = true;
#      desktopManager.kde4.enable = true;
      windowManager.default = "xmonad";
      windowManager.xmonad.extraPackages = haskellPackages: [ haskellPackages.taffybar haskellPackages.xmonadContrib haskellPackages.xmonadExtras ];
       deviceSection =
       		''
                 			Option "RegistryDwords" "EnableBrightnessControl=1"
   		                        '';


    config = ''
    Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "us, no"
        Option "XkbModel" "pc105"
        Option "XkbOptions" "grp:shifts_toggle,ctrl:nocaps"
        EndSection
    '';                                                                  
    exportConfiguration = true;         
    autorun = true;              
    synaptics = {
       enable = true;
       twoFingerScroll = true;
    }; 
  };

   users.mutableUsers = false;
      
   users.extraUsers.stig = {
       group = "users";
       name = "stig";
    createHome = true;
    home = "/home/stig";
    extraGroups = [ "wheel" ];
    uid = 1000;
    shell = "/run/current-system/sw/bin/zsh";
  };
  
  security.sudo.enable = true;

  programs.zsh.enable = true;

   system.activationScripts.dotfiles = {
    # Configure various dotfiles.
    text = ''
      cd /home/stig
      #mkdir .nixpkgs 2>/dev/null || true
      ln -fsn ${./dotfiles/xmonad} .xmonad
    '';
    deps = ["users"];
    };
  
  
} 

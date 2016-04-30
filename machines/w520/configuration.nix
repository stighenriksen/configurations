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

  #  boot.kernelPackages = pkgs.linuxPackages_3_19;
    boot.kernelModules = [ "kvm-intel" "iwlwifi" "iwldvm" ];

  # http://unix.stackexchange.com/questions/163012/iwlwifi-timeout-delays-firmware-to-be-loaded
     services.udev.extraRules = ''
      SUBSYSTEM=="firmware", ACTION=="add", ATTR{loading}="-1"
  '';

  time.timeZone = "Europe/Oslo";

  systemd.services.redshift = {
    wantedBy = [ "multi-user.target"];
    environment = { DISPLAY = ":0"; };
    script = ''
      ${pkgs.redshift}/bin/redshift -l 59:11
    '';
  };

  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql92;
  services.postgresql.enableTCPIP = true;
  services.postgresql.authentication = ''
  # Generated file; do not edit!
   local all all                trust
   host  all all 127.0.0.1/32   trust
   host  all all ::1/128        trust
   host  all all 192.168.1.0/24 trust
            '';
    networking.hostName = "stighenriksen-nixos"; # Define your hostname.
    networking.hostId = "eb210571";
   # networking.wireless.enable = true;
    networking.wireless.interfaces = [ "wlp3s0" ];
    #networking.interfaceMonitor.enable = true;
    networking.wicd.enable = false;
    
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
     nix-repl redshift haskellPackages.cabal2nix
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
   programs.ssh.extraConfig = ''
     Host oldlinode
       HostName 109.74.204.146 
       User stig
     Host linode
       HostName 85.159.213.170
       User stig
   '';
   hardware.opengl.enable = true;
   hardware.opengl.driSupport = true;
   hardware.opengl.driSupport32Bit = true;
   
    hardware.bumblebee.enable = false;
    
    fonts.fontconfig.dpi = 141;
    services.xserver = {
        videoDrivers = [ "nvidia" ];
       enable = true;
      layout = "us";
        displayManager.desktopManagerHandlesLidAndPower = false;


        displayManager.sessionCommands = ''
         sh /home/stig/.fehbg
         ssh-add ~/.ssh/id_rsa
       '';
        

        #displayManager.kdm.enable = true;
          desktopManager.gnome3.enable = true;
      windowManager.xmonad.enable = true;
#      desktopManager.kde4.enable = true;
      windowManager.default = "xmonad";
      windowManager.xmonad.extraPackages = haskellPackages: [ haskellPackages.taffybar haskellPackages.xmonad-contrib haskellPackages.xmonad-extras ];
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

     
  
} 

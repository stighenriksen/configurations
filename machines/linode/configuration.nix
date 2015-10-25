# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let

   sshKeys = import ./private/ssh-keys.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./private/password.nix
      ./hydra/hydra-module.nix
    ];
    
 boot.kernelParams = [ "console=ttyS0" ];
 boot.loader.grub.extraConfig = "serial; terminal_input serial; terminal_output serial";

boot.initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
   environment.systemPackages = with pkgs; [
     git
   ];

  # List services that you want to enable:
  networking.firewall.allowedTCPPorts = [ 80 443 3000 ];

  # Hydra:
  services.hydra = {
  enable = true;
  package = (import ./hydra/release.nix {}).build.x86_64-linux; # or i686-linux if appropriate.
  hydraURL = "http://85.159.213.170:3000";
  notificationSender = "hydra@stighenriksen.com";
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
  programs.zsh.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.haproxy.enable = true;

  services.haproxy.config = ''
     global
       daemon
       maxconn 256

     defaults
       mode http
       timeout connect 5000ms
       timeout client 50000ms
       timeout server 50000ms

     frontend http-in
       bind *:80
       default_backend servers

     backend servers
       server server1 127.0.0.1:8000 maxconn 32
'';
  
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;
  swapDevices = [ { device = "/dev/sda3"; } ];
   users.mutableUsers = false; 
users.defaultUserShell = "/run/current-system/sw/bin/zsh";       
   users.extraUsers.stig = { 
       group = "users"; 
       name = "stig"; 
    createHome = true; 
    home = "/home/stig"; 
    extraGroups = [ "wheel" ]; 
    uid = 1000; 
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [ sshKeys.stig ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

}

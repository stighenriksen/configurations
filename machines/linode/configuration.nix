{ config, pkgs, ... }:

let
   sshKeys = import ./private/ssh-keys.nix;
   hipadvisor = import ./hipadvisor_nix_pkg/default.nix { nixpkgs = pkgs; };
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./private/password.nix
      ./hydra/hydra-module.nix
    ];
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.extraConfig = "serial; terminal_input serial; terminal_output serial";

  boot.initrd.availableKernelModules = [ "virtio_net" "virtio_pci" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio" ];
  virtualisation.docker.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # networking.hostName = "nixos"; # Define your hostname.

  time.timeZone = "Europe/Oslo";

  environment.systemPackages = with pkgs; [
    git
    jdk
    gradle
    nodejs
  ];

  nixpkgs.config.allowUnfree = true; 

  # List services that you want to enable:
  networking.firewall.allowedTCPPorts = [ 80 443 3000 5432 8080];

  # Hydra:
  services.hydra = {
    enable = true;
    package = (import ./hydra/release.nix {}).build.x86_64-linux; # or i686-linux if appropriate.
    hydraURL = "http://85.159.213.170:3000";
    notificationSender = "hydra@stighenriksen.com";
  };

  # Hipadisor:
  systemd.services.hipadvisor = {
     after = [ "network.target" ];
     wantedBy = [ "multi-user.target" ];
     environment = { PORT = "8081"; };
     serviceConfig = {
        User = "jenkins";
        Restart = "always";
      };

     script = ''
       ${pkgs.jdk}/bin/java -jar ${hipadvisor}
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
    host  all all 0.0.0.0/0 md5
    host  all all 192.168.1.0/24 trust
  '';
  programs.zsh.enable = true;

  services.openssh.enable = true;

  services.jenkins.enable = true;

  services.haproxy.enable = true;

  services.haproxy.config = ''
    global
      log 127.0.0.1 local0 notice
      maxconn 2000
      user haproxy
      group haproxy

    defaults
      log     global
      mode    http
      option  httplog
      option  dontlognull
      retries 3
      option redispatch
      timeout connect  5000
      timeout client  10000
      timeout server  10000
    frontend http-in
      bind *:80
      # define hosts
      acl host_alkosalg hdr(host) -i api.alkosalg.no
      acl host_jenkinsalkosalg hdr(host) -i jenkins.alkosalg.no
      acl host_devhipadvisor hdr(host) -i dev.hipadvisor.com
      acl host_jenkinshipadvisor hdr(host) -i jenkins.hipadvisor.com
      use_backend alkosalg_cluster if host_alkosalg
      use_backend jenkins_cluster if host_jenkinsalkosalg
      use_backend devhipadvisor_cluster if host_devhipadvisor
      use_backend jenkins_cluster if host_jenkinshipadvisor
      default_backend alkosalg_cluster
    frontend www-https
      bind *:443 ssl crt /home/stig/sslstuff/alkosalg.pem
      reqadd X-Forwarded-Proto:\ https
      default_backend alkosalg_cluster
      acl host_alkosalg hdr(host) -i alkosalg.no
      use_backend alkosalg_cluster if host_alkosalg
      default_backend alkosalg_cluster
    backend alkosalg_cluster
      redirect scheme https if !{ ssl_fc }
      balance leastconn
      option forwardfor
      server node1 127.0.0.1:3005
    backend jenkins_cluster
      balance leastconn
      option forwardfor
      server node1 127.0.0.1:8080
    backend devhipadvisor_cluster
      balance leastconn
      option forwardfor
      server node1 127.0.0.1:8081
   '';
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

  system.stateVersion = "15.09";

}

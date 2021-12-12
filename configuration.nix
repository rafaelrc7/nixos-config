# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./shell.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader = {
    efi.canTouchEfiVariables = true;
    timeout = 3;

    systemd-boot = {
      enable = true;
      consoleMode = "max";
      editor = false;
      memtest86.enable = true;
    };
  };

  boot.initrd.supportedFilesystems = [ "btrfs" ];

  swapDevices = [
    { device = "/dev/disk/by-partlabel/cryptswap"; randomEncryption.enable = true; }
  ];

  fileSystems."/".options = [ "compress=zstd" "noatime" "nodiratime" "discard" ];
  fileSystems."/home".options = [ "compress=zstd" "noatime" "nodiratime" "discard" ];

  networking.hostName = "omega"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    packageOverrides = pkgs: { unstable = unstable; };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  systemd.network = {
    enable = true;

    netdevs = {
      br0 = {
        enable = true;
        netdevConfig = { Name = "br0"; Kind = "bridge"; };
      };
    };

    networks = {
      wired0 = {
        enable = true;
        matchConfig = { Name = "enp*"; };
        bridge = [ "br0" ];
      };

      br0 = {
        enable = true;
        matchConfig = { Name = "br0"; };
        DHCP = "no";
        address = [ "192.168.0.105/24" ];
        gateway = [ "192.168.0.1" ];
        dns = [ "1.1.1.1" "1.0.0.1" ];
      };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    displayManager = {
      defaultSession = "none+awesome";
    };

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
      ];
    };

  };


  # Configure keymap in X11
  services.xserver.layout = "br";
  services.xserver.xkbVariant = "abnt2";

  # Enable sound.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session.enable = true;
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.zsh;
    users.rafael = {
      isNormalUser = true;
      createHome= true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };
  };
  home-manager.users.rafael = import ./home/rafael/home.nix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      btrfs-progs
      curl
      file
      gnumake
      htop
      killall
      neofetch
      unstable.neovim
      ripgrep
      tmux
      tree
      usbutils
      wget
    ];
    shells = with pkgs; [ bashInteractive zsh ];
    variables = { EDITOR = "nvim"; };
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}


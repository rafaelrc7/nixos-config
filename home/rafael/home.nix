{ config, pkgs, ... }:

{
  imports = [ ./nvim.nix ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rafael";
  home.homeDirectory = "/home/rafael";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = false;

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  home.packages = with pkgs; [
    nur.repos.wolfangaukang.librewolf
    unclutter
    picom
    flameshot
    lxsession
    pcmanfm
    kitty
    keepassxc
    thunderbird
    discord
    slack
    picom
    libsForQt5.okular
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs.git = {
    enable = true;
    userName = "rafaelrc7";
    userEmail = "rafaelrc7@gmail.com";
    extraConfig.init.defaultBranch = "master";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
}


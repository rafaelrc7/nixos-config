{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config.allowUnfree = true; };
in {

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
    packageOverrides = pkgs: { unstable = unstable; };
  };

  home.packages = with pkgs; [
    unstable.neovim
    gcc
    rnix-lsp
    sumneko-lua-language-server
  ];

  home.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
    viAlias = true;
  };

  xdg.configFile.nvim = {
    source = ./config/neovim;
    recursive = true;
  };

}


{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
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


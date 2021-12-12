{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
      zsh-vi-mode
      zsh-nix-shell
      zsh-git-prompt
  ];

  programs.zsh = {
    enable = true;
    histSize = 10000;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    vteIntegration = true;
    enableGlobalCompInit = false; # false because its called below
    shellInit =
    ''
      # Generic extract function
      function extract {
        if [ -z "$1" ]; then
          echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
        else
          if [ -f $1 ]; then
            case $1 in
              *.tar.bz2)   tar xvjf $1    ;;
              *.tar.gz)    tar xvzf $1    ;;
              *.tar.xz)    tar xvJf $1    ;;
              *.lzma)      unlzma $1      ;;
              *.bz2)       bunzip2 $1     ;;
              *.rar)       unrar x -ad $1 ;;
              *.gz)        gunzip $1      ;;
              *.tar)       tar xvf $1     ;;
              *.tbz2)      tar xvjf $1    ;;
              *.tgz)       tar xvzf $1    ;;
              *.zip)       unzip $1       ;;
              *.Z)         uncompress $1  ;;
              *.7z)        7z x $1        ;;
              *.xz)        unxz $1        ;;
              *.exe)       cabextract $1  ;;
              *)           echo "extract: '$1' - unknown archive method" ;;
            esac
          else
            echo "$1 - file does not exist"
          fi
        fi
      }
    '';

    promptInit =
    ''
      autoload -U colors && colors

      prompt() {
        if (($+IN_NIX_SHELL)); then
          PS1="%B%F{blue}nix-shell:%F{cyan}%3~/ %(!.%F{red}#.%F{28}$)%b%f "
        else
          PS1="%B%F{cyan}%3~/ %(!.%F{red}#.%F{28}$)%b%f "
        fi

        RPROMPT="%(?..%B%F{red}<FAIL>%b %?)%f $(git_super_status)"
      }

      precmd_functions+=prompt
    '';

    interactiveShellInit =
    let
      inherit (builtins) concatStringsSep;

      sources = with pkgs; [
        "${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
        "${zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh"
        "${zsh-git-prompt}/share/zsh-git-prompt/zshrc.sh"
      ];
      source = map (source: "source ${source}") sources;
      plugins = concatStringsSep "\n" (source);
    in
    ''
      autoload -Uz compinit
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' menu select
      setopt COMPLETE_ALIASES
      zmodload zsh/complist
      compinit
      _comp_options+=(globdots)		# Include hidden files.

      # Binds arrows to history search
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search
      bindkey "^[[B" down-line-or-beginning-search

      # Coloured less output
      export LESS=-R
      export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
      export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
      export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
      export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
      export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
      export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
      export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

      ${plugins}
    '';
  };
}


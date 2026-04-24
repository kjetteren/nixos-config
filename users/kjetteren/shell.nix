{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      bindkey -e
      bindkey "^[[1;5A" beginning-of-line
      bindkey "^[[1;5B" end-of-line
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey '^H' backward-kill-word
      fastfetch
    '';
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -lh --icons --group-directories-first";
      la = "eza -a --icons --group-directories-first";
      tree = "eza --tree --icons";
      cat = "bat";
      upgrade = "nix flake update --flake /etc/nixos && nh os switch /etc/nixos";
    };
  };

  xdg.configFile."xfce4/helpers.rc".text = ''
    TerminalEmulator=alacritty
  '';
}

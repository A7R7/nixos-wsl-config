{ hostname, ... }:

{
  programs.zsh.enable = true;

  environment.etc."zshrc".text = ''
    setopt autocd nomatch
    unsetopt beep extendedglob notify
    autoload -Uz compinit
    compinit
    zstyle ":completion:*" menu select
    zstyle ":completion:*" matcher-list "" "m:{a-z0A-Z}={A-Za-z}" "r:|=*" "l:|=* r:|=*"
    if type nproc &>/dev/null; then
      export MAKEFLAGS="$MAKEFLAGS -j$(($(nproc)-1))"
    fi
    bindkey '^[[3~' delete-char
    bindkey '^[[5~' beginning-of-buffer-or-history
    bindkey '^[[6~' end-of-buffer-or-history
    bindkey '^[[1;3D' backward-word
    bindkey '^[[1;3C' forward-word
    bindkey '^[[H' beginning-of-line
    bindkey '^[[F' end-of-line
    if [ -f $HOME/.zshrc-personal ]; then
      source $HOME/.zshrc-personal
    fi
    eval "$(starship init zsh)"
    eval "$(direnv hook zsh)"

    alias rebuild-system-test="nh os switch --hostname ${hostname} --dry"
    alias rebuild-system-switch="nh os switch --hostname ${hostname}"
    alias rebuild-system-boot="nh os boot --hostname ${hostname}"
    alias update-system-test="nh os switch --hostname ${hostname} --update --dry"
    alias update-system-switch="nh os switch --hostname ${hostname} --update"
    alias update-system-boot="nh os boot --hostname ${hostname} --update"
    alias system-cleanup="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot"
    alias ..="cd .."
  '';
}

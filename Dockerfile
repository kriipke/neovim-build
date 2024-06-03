FROM alpine:3.20.0 AS base
RUN addgroup -S neovim-users \
  && adduser -S neovim -G neovim-users \
  && mkdir /src && chown -R neovim:neovim-users /src && chmod g+s /src \
  && apk add apk-tools-zsh-completion arping arpwatch asciidoc bat bat-doc bat-zsh-completion ca-certificates ca-certificates-bundle curl-zsh-completion delta delta-zsh-completion exa git-flow git-interactive-rebase-tool tmux-zsh-completion starship-zsh-completion apk apk-tools-zsh-completion arping arpwatch asciidoc bat bat-doc bat-zsh-completion ca-certificates ca-certificates-bundle curl-zsh-completion delta delta-zsh-completion exa git-flow git-interactive-rebase-tool git-warp-time git-zsh-completion github-cli github-cli-doc github-cli-zsh-completion gitlint gitstatus gitstatus-zsh-plugin gkraken gnupg gnupg-dirmngr grub-bash-completion htop hyperfine lnav lnav-doc logrotate logtail lsb-release-minimal ripgrep ripgrep-zsh-completion starship starship-zsh-completion starship-zsh-plugin sudo tmux-zsh-completion trash-cli tree yaml yaml-static yamllint yq-go yq-go-zsh-completion
WORKDIR /src
USER neovim
CMD [ "nvim" ]

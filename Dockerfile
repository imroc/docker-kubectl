FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive

# Install basic tools
RUN apt-get update -y && apt-get install -y software-properties-common build-essential procps curl file git

# Enable man pages
RUN apt-get install -y man-db unminimize && yes | unminimize

# Set timezone and locale
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata locales && \
  ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  locale-gen zh_CN.UTF-8 && \
  update-locale LANG=zh_CN.UTF-8

# Install fish shell
RUN apt-add-repository ppa:fish-shell/release-4 && \
  apt-get update -y && \
  apt-get install fish -y && \
  chsh -s /usr/bin/fish

# Add user linuxbrew to replace the default ubuntu user & group (UID=1000 GID=1000) in Ubuntu 23.04+
RUN touch /var/mail/ubuntu && chown ubuntu /var/mail/ubuntu && userdel -r ubuntu; true && \
  useradd -u 1000 --create-home --shell /bin/bash --user-group linuxbrew

# Cleanup apt cahce
RUN apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install homebrew and tools
USER linuxbrew
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH" \
  XDG_CACHE_HOME=/home/linuxbrew/.cache
RUN brew install kubectl krew kubie kustomize k9s kubecolor helm neovim cfssl openssl fx jq yq yadm zoxide bat ripgrep fzf eza git-delta tig lazygit lua luarocks luajit python
RUN pip3 install virtualenv neovim --break-system-packages

USER root

# # Install kubectl plugins use krew
ENV PATH="/root/.krew/bin:$PATH"
RUN kubectl krew update && \
  kubectl krew install ctx && \
  kubectl krew install kc && \
  kubectl krew install neat && \
  kubectl krew install ns && \
  kubectl krew install view-cert && \
  kubectl krew install whoami && \
  kubectl krew install klock  && \
  kubectl krew index add kvaps https://github.com/kvaps/krew-index && \
  kubectl krew install kvaps/node-shell

# Install rust
ENV PATH="/root/.cargo/bin:$PATH"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
RUN rustup toolchain install nightly

# # Init dotfiles
RUN yadm clone --depth 1 https://github.com/imroc/dotfiles.git && yadm reset --hard HEAD

# Init kubeschemas
RUN git clone --depth 1 https://github.com/imroc/kubeschemas.git /root/.config/kubeschemas

# Init neovim
RUN nvim "+Lazy! install" +qa! 
RUN nvim "+TSInstallSync all" +qa! 
RUN nvim "+MasonInstallAll" +qa! 

CMD ["sleep", "infinity"]

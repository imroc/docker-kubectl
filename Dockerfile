FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
ARG LOCALE=zh_CN.UTF-8

# Install basic tools
RUN apt-get update -y && apt-get install -y software-properties-common build-essential procps curl file git sudo gcc tzdata locales

# Enable man pages
RUN apt-get install -y man-db unminimize && yes | unminimize

# Set timezone and locale
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  locale-gen $LOCALE && \
  update-locale LANG=$LOCALE

# Cleanup apt cahce
RUN apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install homebrew
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH" \
  XDG_CACHE_HOME=/home/linuxbrew/.cache

# Install tools with homebrew
RUN brew install kubectl krew kubie kustomize k9s kubecolor helm \
  neovim cfssl openssl fx jq yq yadm zoxide bat ripgrep fzf eza fish \
  git-delta tig lazygit lua luarocks luajit python node deno expect

# Setup kubectl
ENV PATH="/root/.krew/bin:$PATH"
RUN kubectl krew update && \
  kubectl krew install ctx && \
  kubectl krew install kc && \
  kubectl krew install neat && \
  kubectl krew install ns && \
  kubectl krew install view-cert && \
  kubectl krew install whoami && \
  kubectl krew install klock  && \
  kubectl krew install node-shell && \
  kubectl krew install reap

# Setup dotfiles
RUN git clone --depth 1 https://github.com/imroc/kubeschemas.git /root/.config/kubeschemas && \
  yadm clone --depth 1 https://github.com/imroc/dotfiles.git && \
  yadm reset --hard HEAD && \
  yadm config local.class kube

# Setup neovim
RUN npm install -g neovim && \ 
  pip3 install virtualenv neovim --break-system-packages && \
  nvim --headless "+Lazy! sync" +qa! && \
  nvim --headless "+Lazy! load all" "+MasonInstallAll" +qa! 

# Setup fish shell
RUN chsh -s /home/linuxbrew/.linuxbrew/bin/fish && expect -c 'spawn fish; send "exit\n"; expect eof'

CMD ["sleep", "infinity"]

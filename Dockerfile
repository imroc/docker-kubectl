FROM ubuntu:24.04
ARG USER_ID=666
ARG USER_NAME=kube
ARG DEBIAN_FRONTEND=noninteractive
ARG LOCALE=zh_CN.UTF-8

# Install basic tools
RUN apt-get update -y && \
  apt-get install -y software-properties-common build-essential \
  procps curl file git sudo gcc tzdata locales man-db unminimize

# Enable man pages
RUN yes | unminimize

# Set timezone and locale
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  locale-gen ${LOCALE} && \
  update-locale LANG=${LOCALE}

# Cleanup apt cahce
RUN apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

# Add user linuxbrew user
RUN useradd --create-home --shell /bin/bash -u ${USER_ID} --user-group ${USER_NAME} && \
  echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers && \
  echo "linuxbrew ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

USER ${USER_NAME}

# Install homebrew
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"

# Install tools with homebrew
RUN brew install kubectl krew kubie kustomize k9s kubecolor helm \
  neovim vim cfssl openssl fx jq yq yadm zoxide bat ripgrep fzf eza \
  git-delta tig lazygit lua luarocks luajit python node deno expect fish

# Setup kubectl plugins
ENV PATH="/home/${USER_NAME}/.krew/bin:$PATH"
RUN kubectl krew update && \
  kubectl krew install ctx ns kc neat whoami view-cert klock node-shell reap

# Setup dotfiles
RUN git clone --depth 1 https://github.com/imroc/kubeschemas.git /home/${USER_NAME}/.config/kubeschemas && \
  yadm clone --depth 1 https://github.com/imroc/dotfiles.git && \
  yadm reset --hard HEAD && \
  yadm config local.class kube && \
  bat cache --build

# Setup neovim
RUN npm install -g neovim && \ 
  pip3 install virtualenv neovim --break-system-packages && \
  nvim --headless "+Lazy! sync" +qa! && \
  nvim --headless "+Lazy! load all" "+MasonInstallAll" +qa! 

# Setup fish shell
RUN sudo chsh -s /home/linuxbrew/.linuxbrew/bin/fish ${USER_NAME} && \
  expect -c 'spawn fish; send "exit\n"; expect eof'

CMD ["sleep", "infinity"]

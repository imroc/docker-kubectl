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

# Init kubeschemas
RUN git clone --depth 1 https://github.com/imroc/kubeschemas.git /root/.config/kubeschemas
# # Init dotfiles
RUN yadm clone --depth 1 https://github.com/imroc/dotfiles.git && yadm reset --hard HEAD

# Init neovim
RUN nvim --headless "+Lazy! install" +qa! 
RUN cd /root/.local/share/nvim/lazy/blink.cmp && cargo build --release
RUN nvim --headless "+TSInstallSync all" +qa! 
RUN nvim --headless "+MasonInstallAll" +qa! 

CMD ["sleep", "infinity"]

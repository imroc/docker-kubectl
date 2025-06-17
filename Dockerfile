FROM ubuntu:24.04

# Update apt
RUN apt-get update -y

# Install kubectl
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg && \ 
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
  && chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
  chmod 644 /etc/apt/sources.list.d/kubernetes.list && \
  apt-get update -y && \
  apt-get install -y kubectl

# Install other tools
RUN apt install -y vim

# Cleanup apt
RUN apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

CMD ["sleep", "infinity"]

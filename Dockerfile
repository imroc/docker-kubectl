FROM ubuntu:24.04

# Update apt
RUN sudo apt-get update -y

# Install kubectl
RUN sudo apt-get install -y apt-transport-https ca-certificates curl gnupg && \ 
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
  && sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -y && \
  sudo apt-get install -y kubectl

# Install other tools
RUN sudo apt install -y vim

# Cleanup apt
RUN apt-get clean autoclean && \
  apt-get autoremove --yes && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

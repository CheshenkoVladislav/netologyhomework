#cloud-config
datasource:
  Ec2:
    strict_id: false
ssh_pwauth: no
users:
- name: ubuntu
  sudo: 'ALL=(ALL) NOPASSWD:ALL'
  shell: /bin/bash
  ssh_authorized_keys:
  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLrXGUaqctNbryc8HL+qO8LlpNAoaswCUl2FYC0qQcv vcheshenko@vcheshenko-VirtualBox"

package_update: true
runcmd:
  - |
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

  - CODENAME=$(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}")
  
  - echo "Types:deb" | sudo tee /etc/apt/sources.list.d/docker.sources
  - echo "URIs:https://download.docker.com/linux/ubuntu" | sudo tee -a /etc/apt/sources.list.d/docker.sources
  - echo "Suites:$CODENAME" | sudo tee -a /etc/apt/sources.list.d/docker.sources
  - echo "Components:stable" | sudo tee -a /etc/apt/sources.list.d/docker.sources
  - echo "Signed-By:/etc/apt/keyrings/docker.asc" | sudo tee -a /etc/apt/sources.list.d/docker.sources

  - sudo apt update
  - sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  - mkdir ~/testdir
  - |
    echo ${token}|docker login \
      --username oauth \
      --password-stdin \
      cr.yandex
  - mkdir -p /home/ubuntu/.docker
  - cp /root/.docker/config.json /home/ubuntu/.docker
  - chown -R ubuntu:ubuntu /home/ubuntu/.docker
  - chmod 600 /home/ubuntu/.docker/config.json

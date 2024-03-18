#!/bin/bash

read -p "This script will install k8s with kubeadm. \n Are you running this on your first Master Node or a Worker Node? [1 or 2] " response
response=${response,,}

# installing for master node
if [[ $response = 1 ]]; then
   printf "\n####\n# Installing k8s the Master Node \n####\n#";
# Add Docker's official GPG key:
   sudo apt-get update -y
   sudo apt-get install ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
   echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update -y
   sudo apt-get install docker-ce docker-ce-cli containerd.io -y
   curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
   echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
   sudo apt-get update -y
   sudo apt-get install -y kubelet kubeadm kubectl
   sudo apt-mark hold kubelet kubeadm kubectl
   FILE_PATH="/etc/containerd/config.toml"
   sudo sed -i '/disabled_plugins = \["cri"\]/s/^/#/' "$FILE_PATH"
   sudo systemctl restart containerd
   sudo kubeadm init --pod-network-cidr=192.168.0.0/16
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
# Done. print token
   printf "All done! please past the following token on the woker nodes to join them:\n"
   printf "(create a new one with 'kubeadm token create --print-join-command')\n"
   kubeadm token create --print-join-command
 fi

# installing for worker node
if [[ $response = 2 ]]; then
   printf "\n####\n# Installing k8s on a Worker Node \n####\n#";
   read -p "please paste the join token: " token
# Add Docker's official GPG key:
   sudo apt-get update -y
   sudo apt-get install ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
   echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update -y
   sudo apt-get install docker-ce docker-ce-cli containerd.io -y
   curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
   echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
   sudo apt-get update -y
   sudo apt-get install -y kubelet kubeadm kubectl
   sudo apt-mark hold kubelet kubeadm kubectl
   FILE_PATH="/etc/containerd/config.toml"
   sudo sed -i '/disabled_plugins = \["cri"\]/s/^/#/' "$FILE_PATH"
   sudo systemctl restart containerd
   kubeadm join 192.168.1.130:6443 --token $token
   printf "All done! if this node is not joined please enter the join command to join a cluster"
 fi

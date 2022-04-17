#!/bin/zsh

# Upgrade everything
sudo apt update && sudo apt upgrade -y

# AWS cli
echo -e "complete -C /usr/local/bin/aws_completer aws" >> ~/.zshrc

# Kubectl
echo -e "alias k='kubectl'" >> ~/.zshrc
echo -e "alias k-config='aws eks update-kubeconfig --name test-cluster --region ca-central-1'" >> ~/.zshrc
echo -e "source <(kubectl completion zsh)" >> ~/.zshrc
echo -e "complete -F __start_kubectl k" >> ~/.zshrc

# Terraform
echo -e "alias tf='terraform'" >> ~/.zshrc
echo -e "complete -F __start_terraform tf" >> ~/.zshrc
terraform -install-autocomplete

# Eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

source ~/.zshrc

#!/bin/bash

# AWS cli autocomplete and aliases
echo -e "complete -C /usr/local/bin/aws_completer aws" >> ~/.zshrc

# Kubectl aliases and command autocomplete
echo -e "alias k='kubectl'" >> ~/.zshrc
echo -e "alias k-config='aws eks --region ca-central-1 update-kubeconfig --name test_cluster'" >> ~/.zshrc
echo -e "source <(kubectl completion zsh)" >> ~/.zshrc
echo -e "complete -F __start_kubectl k" >> ~/.zshrc

# Kubectl aliases and command autocomplete
echo -e "alias tf='terraform'" >> ~/.zshrc
echo -e "complete -F __start_terraform tf" >> ~/.zshrc
terraform -install-autocomplete

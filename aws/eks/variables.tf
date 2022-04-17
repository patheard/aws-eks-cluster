variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "cluster_addon_coredns_version" {
  description = "Version of the EKS cluster CoreDNS addon"
  type        = string
}

variable "cluster_addon_kube_proxy_version" {
  description = "Version of the EKS cluster kube-proxy addon"
  type        = string
}

variable "cluster_addon_vpc_cni_version" {
  description = "Version of the EKS cluster VPC CNI addon"
  type        = string
}

variable "node_group_ami_version" {
  description = "AMI version to deploy to the EKS node group"
  type        = string
}

variable "node_group_instance_type" {
  description = "Instance type to use for the EKS node group"
  type        = string
}

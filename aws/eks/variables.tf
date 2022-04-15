variable "cluster_version" {
    description = "Version of the EKS cluster"
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

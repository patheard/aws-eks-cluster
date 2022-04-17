###
# AWS EKS Cluster configuration
###

resource "aws_eks_cluster" "test_cluster" {
  name     = "test-cluster"
  role_arn = aws_iam_role.test_cluster_role.arn
  version  = var.cluster_version

  enabled_cluster_log_types = ["api", "audit", "controllerManager", "scheduler", "authenticator"]

  vpc_config {
    security_group_ids = [
      aws_security_group.test_cluster_worker.id
    ]
    subnet_ids = module.vpc.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

resource "aws_security_group" "test_cluster_worker" {
  name   = "test-cluster-worker"
  vpc_id = module.vpc.vpc_id
}

###
# AWS EKS Nodegroup configuration
###

resource "aws_eks_node_group" "test_cluster_node_group" {
  cluster_name    = aws_eks_cluster.test_cluster.name
  node_group_name = "test-cluster-node-group"
  node_role_arn   = aws_iam_role.test_cluster_worker_role.arn
  subnet_ids      = module.vpc.private_subnet_ids

  release_version = var.node_group_ami_version
  instance_types  = [var.node_group_instance_type]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-worker-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-worker-AmazonEKS_CNI_Policy
  ]
}

###
# AWS EKS addons
###

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.test_cluster.name
  addon_name        = "coredns"
  addon_version     = var.cluster_addon_coredns_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.test_cluster.name
  addon_name        = "kube-proxy"
  addon_version     = var.cluster_addon_kube_proxy_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.test_cluster.name
  addon_name        = "vpc-cni"
  addon_version     = var.cluster_addon_vpc_cni_version
  resolve_conflicts = "OVERWRITE"
}

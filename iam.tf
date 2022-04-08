###
# AWS EKS IAM cluster roles
###

resource "aws_iam_role" "test_cluster_role" {
  name = "test_cluster_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.test_cluster_role.name
}

# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.test_cluster_role.name
}


###
# AWS EKS IAM worker role
###

resource "aws_iam_role" "test_cluster_worker_role" {
  name = "test_cluster_worker_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.test_cluster_worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.test_cluster_worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.test_cluster_worker_role.name
}

# Reference: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html
resource "aws_iam_role_policy_attachment" "eks-worker-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.test_cluster_worker_role.name
}

###
# Application level policies
###

resource "aws_iam_policy" "notification-worker-policy" {
  name        = "notification-worker-policy"
  description = "Permissions for a notification worker"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "mobiletargeting:*",
        "ses:SendEmail",
        "ses:SendRawEmail",
        "sqs:*",
        "sns:Publish",
        "securityhub:BatchImportFindings",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "notification-worker-policy" {
  policy_arn = aws_iam_policy.notification-worker-policy.arn
  role       = aws_iam_role.test_cluster_worker_role.name
}

###
# AWS EKS Service account
###

data "tls_certificate" "notification-canada-ca" {
  url = aws_eks_cluster.test_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "notification-canada-ca" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.notification-canada-ca.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.test_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eks-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.notification-canada-ca.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:notification-canada-ca:notification-service-account"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.notification-canada-ca.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "notification-service-account-role" {
  assume_role_policy = data.aws_iam_policy_document.eks-assume-role-policy.json
  name               = "notification-service-account-role"
}

resource "aws_iam_role_policy_attachment" "notification-service-worker-policy" {
  policy_arn = aws_iam_policy.notification-worker-policy.arn
  role       = aws_iam_role.notification-service-account-role.name
}
# AWS EKS Cluster
Creates an EKS cluster and managed node group to test cluster upgrades.

```sh
# Init, plan and apply
cd aws/eks
terraform init
terraform plan
terraform apply
```

# Update cluster addons
After an upgrade, bump the versions of the following addons:

* [coredns](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
* [kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
* [vpc-cni](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)

This is controlled with [Terraform `aws_eks_addon` resources](https://github.com/patheard/aws-eks-cluster/blob/99797b1766008755067692bd1e5e02639b509435/aws/eks/eks.tf#L64-L83).

# Test
Creates an nginx deployment and port forwards so you can access it from http://localhost:8080.

```sh
# generate the kubeconfig
k-config

# Create an nginx deployment
kubectl create -f https://k8s.io/examples/admin/namespace-dev.json
kubectl apply -f https://k8s.io/examples/controllers/nginx-deployment.yaml -n development
kubectl get pods -n development
kubectl port-forward $NGINX_POD 8080:80
```

# Service account
To grant IAM permissions to pods, associate them with a [service account](https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html):

1. Create an `s3-read` serviceaccount in the `development` namespace
2. Annotate pods with `serviceAccountName: s3-read` to provide them with the `TestClusterServiceAccount` IAM role's permissions

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: development
  name: s3-read
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::$AWS_ACCOUNT_ID:role/TestClusterServiceAccount
```
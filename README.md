# AWS EKS Cluster
Creates an EKS cluster and managed node group to test cluster upgrades with.

```sh
# Plan and apply
cd aws/eks
terraform plan
terraform apply
```

# Update command
Use the following eksctl commands to update:
* [coredns](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
* [kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
* [vpc-cni](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
```sh
# Addons
export ADDON_NAME="coredns" # or "kube-proxy", "vpc-cni"
export ADDON_VERSION="1.10.2-eksbuild.1" # specific to the addon and k8s version
export AWS_REGION="ca-central-1"
export CLUSTER_NAME="test_cluster"

eksctl create addon \
    --name "$ADDON_NAME" \
    --cluster "$CLUSTER_NAME" \
    --force
eksctl get addon \
    --name "$ADDON_NAME" \
    --cluster "$CLUSTER_NAME"
eksctl update addon \
    --name "$ADDON_NAME" \
    --cluster "$CLUSTER_NAME" \
    --version "$ADDON_VERSION" \
    --force
```

# Test deployment
```sh
k-config # generate the kubeconfig

# Create an nginx deployment
kubectl create -f https://k8s.io/examples/admin/namespace-dev.json
kubectl apply -f https://k8s.io/examples/controllers/nginx-deployment.yaml -n development
kubectl get pods -n development
kubectl port-forward $NGINX_POD 8080:80
```
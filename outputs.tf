output "aws_eks_cluster" {
    value = local.cluster_name
}

output "aws_hostname" {
    value = data.kubernetes_ingress_v1.ingress_hostname.status.0.load_balancer.0.ingress.0.hostname
}
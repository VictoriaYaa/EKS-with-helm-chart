resource "kubernetes_namespace" "vic-ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "httpbin" {
  name       = "httpbin"
  repository = "https://estahn.github.io/charts"
  chart      = "httpbingo"
  namespace = kubernetes_namespace.vic-ns.metadata[0].name

  values = [
    templatefile("${path.module}/httpbin-values.yaml",{ host = "${data.kubernetes_ingress_v1.ingress_hostname.status.0.load_balancer.0.ingress.0.hostname}" })
  ]

#   values = [
#     file("${path.module}/httpbin-values.yaml")
#   ]
}

data "kubernetes_ingress_v1" "ingress_hostname" {
  metadata {
    name = "httpbin"
    namespace = kubernetes_namespace.vic-ns.metadata[0].name
  }
}


resource "helm_release" "alb-controller" {
 name       = "aws-load-balancer-controller"
 repository = "https://aws.github.io/eks-charts"
 chart      = "aws-load-balancer-controller"
 namespace  = kubernetes_namespace.vic-ns.metadata[0].name

 set {
     name  = "region"
     value = var.aws_region
 }

 set {
     name  = "vpcId"
     value = module.vpc.vpc_id
 }

 set {
     name  = "image.repository"
     value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
 }

 set {
     name  = "serviceAccount.create"
     value = "true"
 }

 set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.kubernetes_alb_controller[0].arn
  }

  set {
    name  = "enableServiceMutatorWebhook"
    value = "true"
  }

 set {
     name  = "clusterName"
     value = local.cluster_name
 }
 }

 resource "aws_iam_policy" "kubernetes_alb_controller" {
  depends_on  = [var.mod_dependency]
  count       = var.enabled ? 1 : 0
  name        = "${local.cluster_name}-alb-controller"
  path        = "/"
  description = "Policy for load balancer controller service"

  policy = file("${path.module}/alb_controller_iam_policy.json")
}
# Roles for ALB controller
data "aws_iam_policy_document" "kubernetes_alb_controller_assume" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "kubernetes_alb_controller" {
  count              = var.enabled ? 1 : 0
  name               = "${local.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.kubernetes_alb_controller_assume[0].json
}

resource "aws_iam_role_policy_attachment" "kubernetes_alb_controller" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.kubernetes_alb_controller[0].name
  policy_arn = aws_iam_policy.kubernetes_alb_controller[0].arn
}


# IAM for tf user
resource "aws_iam_user" "terraform" {
  name = "terraform"
}

data "aws_iam_policy" "admin_terraform_policy" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_policy_attachment" "attach_to_tf" {
  user       = aws_iam_user.terraform.name
  policy_arn = data.aws_iam_policy.admin_terraform_policy.arn
}
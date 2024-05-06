resource "aws_ecr_repository" "httpbin" {
  name                 = "httpbin"

  image_scanning_configuration {
    scan_on_push = true
  }
}
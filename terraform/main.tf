provider "aws" {
  region = var.aws_region
}

# ECR repository
resource "aws_ecr_repository" "registry" {
  name = var.aws_ecr_repository
}

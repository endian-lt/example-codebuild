# CodeBuild project
resource "aws_codebuild_project" "codebuild" {
  name          = "${var.prefix}-codebuild"
  build_timeout = "6" # in minutes
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "AWS_CODECOMMIT_REPOSITORY"
      value = var.aws_codecommit_repository
    }
  }

  source {
    type      = "CODECOMMIT"
    location  = "https://git-codecommit.${var.aws_region}.amazonaws.com/v1/repos/${var.aws_codecommit_repository}"
  }

  source_version = "master"
}

# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.prefix}-codebuild"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
      },
    ]
  })
}

# IAM policy to allow CodeBuild to interact with ECR
resource "aws_iam_policy" "codebuild_policy" {
  name   = "${var.prefix}-codebuild-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:CreateLogStream"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
          "codecommit:GitPull",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository"
        ],
        "Resource": "*"
      }
  ]
}
EOF
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "codebuild_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}
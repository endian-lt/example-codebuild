# CloudWatch Event Rule to trigger CodeBuild on CodeCommit changes
resource "aws_cloudwatch_event_rule" "cloudwatch" {
  name        = "${var.prefix}-codebuild"
  description = "Trigger CodeBuild on CodeCommit push"

  event_pattern = jsonencode({
    source: ["aws.codecommit"],
    "detail-type": ["CodeCommit Repository State Change"],
    resources: ["arn:aws:codecommit:${var.aws_region}:${var.aws_account_id}:${var.aws_codecommit_repository}"],
    detail: {
      event: ["referenceCreated", "referenceUpdated"],
      referenceType: ["branch"],
      referenceName: ["master"]
    }
  })
}

# CloudWatch Event Target to associate the rule with CodeBuild
resource "aws_cloudwatch_event_target" "example" {
  rule = aws_cloudwatch_event_rule.cloudwatch.name
  arn  = aws_codebuild_project.codebuild.arn
  role_arn = aws_iam_role.cloudwatch_role.arn
}

resource "aws_iam_role" "cloudwatch_role" {
  name = "${var.prefix}-codebuild-cloudwatch"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Service: "events.amazonaws.com"
        },
        Action: "sts:AssumeRole"
      }
    ]
  })
}

# Permission for CloudWatch Events to trigger the CodeBuild project
resource "aws_iam_policy" "cloudwatch_policy" {
  name   = "${var.prefix}-codebuild-cloudwatch-policy"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: "codebuild:StartBuild",
        Resource: aws_codebuild_project.codebuild.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attachment" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

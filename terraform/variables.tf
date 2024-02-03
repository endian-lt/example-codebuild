# Set up AWS provider
variable "aws_region" {
  default     = "eu-central-1"
}

variable "aws_account_id" {
  default = "XXXXXXXXXXXX"
}

variable "aws_ecr_repository" {
  default = "example-codebuild"
}

variable "aws_codecommit_repository" {
  default = "example-codebuild"
}

variable "tags" {
  type        = map(string)
  description = "A common tags for the project"
  default = {"project":"example-codebuild", "area": "example"}
}

variable "prefix" {
  default     = "example"
}

variable "aws_region" {
  description = "AWS region used for the Terraform state bucket."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used as the S3 bucket prefix."
  type        = string
  default     = "rodrigo-devops"
}

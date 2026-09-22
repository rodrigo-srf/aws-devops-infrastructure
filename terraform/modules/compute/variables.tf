variable "project_name" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }
variable "subnet_id" { type = string }
variable "ami_id" { type = string }

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "container_image" {
  description = "ECR image URI including tag."
  type        = string
}

variable "ecr_repository_arn" { type = string }
variable "s3_prefix_list_id" { type = string }

variable "allowed_http_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

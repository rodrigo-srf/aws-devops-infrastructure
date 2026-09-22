variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "aws-devops-infrastructure"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to reach the application over HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "image_tag" {
  type    = string
  default = "latest"
}

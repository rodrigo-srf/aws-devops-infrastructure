variable "project_name" { type = string }
variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }

variable "public_subnet_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "A public subnet CIDR must be provided for every availability zone."
  }
}

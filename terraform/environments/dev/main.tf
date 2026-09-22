data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "network" {
  source = "../../modules/network"

  project_name        = var.project_name
  vpc_cidr            = "10.20.0.0/16"
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs = ["10.20.10.0/24", "10.20.20.0/24"]
}

module "registry" {
  source       = "../../modules/registry"
  project_name = var.project_name
}

module "compute" {
  source = "../../modules/compute"

  project_name       = var.project_name
  aws_region         = var.aws_region
  vpc_id             = module.network.vpc_id
  subnet_id          = module.network.public_subnet_ids[0]
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  allowed_http_cidrs = var.allowed_http_cidrs

  container_image    = "${module.registry.repository_url}:${var.image_tag}"
  ecr_repository_arn = module.registry.repository_arn
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

module "network" {
  source = "../../modules/network"

  project_name        = var.project_name
  aws_region          = var.aws_region
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
  vpc_cidr           = "10.20.0.0/16"
  subnet_id          = module.network.public_subnet_ids[0]
  ami_id             = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type      = var.instance_type
  allowed_http_cidrs = var.allowed_http_cidrs

  container_image    = "${module.registry.repository_url}:${var.image_tag}"
  ecr_repository_arn = module.registry.repository_arn
  s3_prefix_list_id  = module.network.s3_prefix_list_id
}

output "application_url" { value = module.compute.application_url }
output "instance_id" { value = module.compute.instance_id }
output "ecr_repository_url" { value = module.registry.repository_url }
output "vpc_id" { value = module.network.vpc_id }

output "state_bucket_name" {
  description = "S3 bucket created for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}

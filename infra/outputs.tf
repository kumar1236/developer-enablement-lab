output "repository_url" {
  description = "ECR destination for container images"
  value       = aws_ecr_repository.app.repository_url
}

output "repository_arn" {
  description = "ECR ARN used when defining IAM permissions"
  value       = aws_ecr_repository.app.arn
}
output "repository_url" {
  description = "ECR destination for container images"
  value       = aws_ecr_repository.app.repository_url
}

output "repository_arn" {
  description = "ECR ARN used when defining IAM permissions"
  value       = aws_ecr_repository.app.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}

output "deployed_image" {
  value = var.app_image
}
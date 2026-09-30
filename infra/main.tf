
variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "ap-south-1"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "developer-enablement-lab"
      Environment = "lab"
      ManagedBy   = "OpenTofu"
    }
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "developer-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
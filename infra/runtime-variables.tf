variable "app_image" {
  description = "Exact container image to deploy, identified by digest"
  type        = string

  default = "115278085846.dkr.ecr.ap-south-1.amazonaws.com/developer-service@sha256:ef46f217e4d51e49a63baa20f27f0a5ff9231055310f560f468f11e17ea14772"
}


variable "execution_role_arn" {
  description = "Existing ECS task execution role"
  type        = string

  default = "arn:aws:iam::115278085846:role/developer-service-execution"
}

variable "allowed_client_cidr" {
  description = "Your public IPv4 address with a /32 suffix"
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.allowed_client_cidr)) &&
      endswith(var.allowed_client_cidr, "/32")
    )
    error_message = "Use one public IPv4 address with /32."
  }
}

variable "newrelic_headers_secret_arn" {
  description = "Secrets Manager ARN containing OTLP authentication headers"
  type        = string
}
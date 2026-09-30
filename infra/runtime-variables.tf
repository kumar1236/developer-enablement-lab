variable "app_image" {
  description = "Exact container image to deploy, identified by digest"
  type        = string

  default = "115278085846.dkr.ecr.ap-south-1.amazonaws.com/developer-service@sha256:49d12180d808132415edc2d06b0d7f0fa655820fe1c4555df84da85b65694063"
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
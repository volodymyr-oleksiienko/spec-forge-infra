variable "tf_cloud_organization" {
  description = "Terraform Cloud organization name"
  type        = string
}

variable "tf_cloud_workspace" {
  description = "Terraform Cloud workspace name"
  type        = string
}

variable "gh_target_repositories" {
  description = "Repositories that receive SERVER_IP secret"
  type        = list(string)
}

variable "digital_ocean_token" {
  description = "DigitalOcean API token"
  sensitive   = true
}

variable "gh_secret_sync_token" {
  description = "Github API token"
  sensitive   = true
}

variable "server_ssh_public_key" {
  description = "SSH public key injected into the server"

  validation {
    condition     = length(trimspace(var.server_ssh_public_key)) > 50
    error_message = "SSH public key must not be empty or invalid"
  }
}

variable "domain_name" {
  description = "Primary domain name"
  default     = "v-oleksiienko.xyz"

  validation {
    condition     = can(regex("^[a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid DNS name"
  }
}

variable "environment" {
  default = "prod"
}

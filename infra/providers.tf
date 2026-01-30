terraform {
  required_version = "~> 1.14"

  cloud {
    organization = "VolodymyrOleksiienko"
    workspaces {
      name = "spec-forge-infra"
    }
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "digitalocean" {
  token = var.digital_ocean_token
}

provider "github" {
  token = var.gh_secret_sync_token
}
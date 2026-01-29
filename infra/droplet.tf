data "local_file" "docker_compose" {
  filename = "${path.module}/docker-compose.yml"
}

resource "digitalocean_ssh_key" "default" {
  name = "github-actions-key"
  public_key = var.server_ssh_public_key
}

resource "digitalocean_volume" "data" {
  region                  = "ams3"
  name                    = "spec-forge-data"
  size                    = 10
  initial_filesystem_type = "ext4"

  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_droplet" "web" {
  name = "spec-forge-server"
  image = "ubuntu-24-04-x64"
  region = "ams3"
  size = "s-1vcpu-1gb"
  volume_ids = [digitalocean_volume.data.id]
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
  monitoring = true

  tags = [
    "env-${var.environment}",
    "project-spec-forge"
  ]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    docker_compose_yml = replace(data.local_file.docker_compose.content, "$${domain_name}", var.domain_name)
  })
}
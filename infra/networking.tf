resource "digitalocean_firewall" "web" {
  name = "spec-forge-firewall"

  droplet_ids = [digitalocean_droplet.web.id]

  tags = [
    "env-${var.environment}",
    "project-spec-forge"
  ]

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_reserved_ip" "static_ip" {
  region = digitalocean_droplet.web.region
}

resource "digitalocean_reserved_ip_assignment" "assign" {
  ip_address = digitalocean_reserved_ip.static_ip.ip_address
  droplet_id = digitalocean_droplet.web.id
}
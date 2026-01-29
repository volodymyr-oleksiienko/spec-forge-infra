resource "digitalocean_domain" "default" {
  name = var.domain_name
  ip_address = digitalocean_reserved_ip.static_ip.ip_address
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.default.name
  type = "A"
  name = "www"
  value = digitalocean_reserved_ip.static_ip.ip_address
  ttl = 1800
}
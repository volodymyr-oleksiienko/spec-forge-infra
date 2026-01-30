output "domain_name" {
  value = var.domain_name
}

output "reserved_ip" {
  value = digitalocean_reserved_ip.static_ip.ip_address
}
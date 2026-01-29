resource "github_actions_secret" "server_ip" {
  for_each = toset(var.gh_target_repositories)

  repository      = each.value
  secret_name     = "SERVER_IP"
  plaintext_value = digitalocean_reserved_ip.static_ip.ip_address
}
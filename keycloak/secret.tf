output "client_secret" {
  value     = keycloak_openid_client.openid_client.client_secret
  sensitive = true 
}

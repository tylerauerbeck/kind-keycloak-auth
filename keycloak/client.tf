resource "keycloak_openid_client" "openid_client" {
  realm_id            = keycloak_realm.nightosphere.id
  client_id           = "kubeosphere"

  name                = "Kubeosphere"
  enabled             = true

  description	      = "Kubeosphere SSO"

  access_type         = "CONFIDENTIAL"
  valid_redirect_uris = [
    "http://*",
    "https://*"
  ]
  web_origins = [
    "http://*",
    "https://*"
  ]

  direct_access_grants_enabled = true
  standard_flow_enabled = true
  service_accounts_enabled = true

  authorization {
    policy_enforcement_mode = "ENFORCING"
  }
}

resource "keycloak_openid_client_scope" "groups_client_scope" {
  realm_id               = keycloak_realm.nightosphere.id
  name                   = "groups"
  description            = "When requested, this scope will map a user's group memberships to a claim"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  realm_id        = keycloak_realm.nightosphere.id
  client_scope_id = keycloak_openid_client_scope.groups_client_scope.id
  name            = "groups"

  claim_name = "groups"
  full_path = false
}

resource "keycloak_openid_user_attribute_protocol_mapper" "name_user_attribute_mapper" {
  realm_id        = keycloak_realm.nightosphere.id
  client_scope_id = keycloak_openid_client_scope.groups_client_scope.id
  name            = "name"

  user_attribute  = "name"
  claim_name      = "name"
}

data "keycloak_openid_client_scope" "email" {
  realm_id = keycloak_realm.nightosphere.id
  name     = "email"
}

resource "keycloak_openid_client_default_scopes" "my_default_scopes" {
  realm_id  = keycloak_realm.nightosphere.id
  client_id = keycloak_openid_client.openid_client.id

  default_scopes = [
    keycloak_openid_client_scope.groups_client_scope.name,
    data.keycloak_openid_client_scope.email.name
  ]
}

resource "keycloak_user" "finn" {
  realm_id = keycloak_realm.nightosphere.id
  username = "finn"
  enabled  = true

  email      = "finn@nightosphere.dev"
  email_verified = true
  first_name = "Finn"
  last_name  = "Thehuman"

  initial_password {
    value     = "hello123"
    temporary = false
  }
}

resource "keycloak_user" "jake" {
  realm_id = keycloak_realm.nightosphere.id
  username = "jake"
  enabled  = true

  email      = "jake@nightosphere.dev"
  email_verified = true
  first_name = "Jake"
  last_name  = "Thedog"

  initial_password {
    value     = "hello123"
    temporary = false
  }
}

resource "keycloak_group" "humans" {
  realm_id = keycloak_realm.nightosphere.id
  name     = "Humans"
}

resource "keycloak_group" "nothumans" {
  realm_id = keycloak_realm.nightosphere.id
  name     = "Nothumans"
}

resource "keycloak_user_groups" "finn_user_groups" {
  realm_id = keycloak_realm.nightosphere.id
  user_id = keycloak_user.finn.id

  group_ids  = [
    keycloak_group.humans.id
  ]
}

resource "keycloak_user_groups" "jake_user_groups" {
  realm_id = keycloak_realm.nightosphere.id
  user_id = keycloak_user.jake.id

  group_ids  = [
    keycloak_group.nothumans.id
  ]
}

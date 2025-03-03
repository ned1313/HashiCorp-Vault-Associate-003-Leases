path "database/creds/readonly" {
  capabilities = ["read"]
}

path "sys/leases/revoke/database/creds/readonly/*" {
  capabilities = ["create", "update"]
}
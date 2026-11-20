vault {
  address = "http://127.0.0.1:8200"
}

auto_auth {
  method "approle" {
    mount_path = "auth/approle"
    config = {
      role_id_file_path                   = "./vault/config/role_id"
      secret_id_file_path                 = "./vault/config/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }
}

template {
  source      = "./vault/templates/server.crt.ctmpl"
  destination = "./certs/server.crt"
  perms       = "0644"
  command     = "nginx -p $(pwd) -c nginx.conf -s reload || true"
}

template {
  source      = "./vault/templates/server.key.ctmpl"
  destination = "./certs/server.key"
  perms       = "0600"
  command     = "nginx -p $(pwd) -c nginx.conf -s reload || true"
}

template {
  source      = "./vault/templates/ca.crt.ctmpl"
  destination = "./certs/ca.crt"
  perms       = "0644"
  command     = "nginx -p $(pwd) -c nginx.conf -s reload || true"
}

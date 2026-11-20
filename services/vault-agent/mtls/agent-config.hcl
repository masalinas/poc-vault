vault {
  address = "http://vault-server:8200"
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
  source      = "/vault/templates/ca.crt.ctmpl"
  destination = "/certs/ca.crt"
  perms       = "0644"
}

template {
  source      = "/vault/templates/server.pem.ctmpl"
  destination = "/certs/server.pem"
  perms       = "0600"
  command     = "curl -s --unix-socket /var/run/docker.sock -X POST http://localhost/containers/nginx-container/kill?signal=HUP || true"
}
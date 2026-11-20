vault {
  address = "http://127.0.0.1:8200"
}

auto_auth {
  method "approle" {
    config = {
      role_id_file_path                   = "./role_id.txt"
      secret_id_file_path                 = "./secret_id.txt"
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "./vault-token"
    }
  }
}

template_config {
  static_secret_render_interval = "10s"
  exit_on_retry_failure         = true
}

template {
  source      = "./app.env.ctmpl"
  destination = "./app.env"
  # Opcional: comando a ejecutar cada vez que el secreto cambie
  # command   = "systemctl reload mi-app"
}

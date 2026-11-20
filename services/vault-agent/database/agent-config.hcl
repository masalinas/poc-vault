vault {
  address = "http://127.0.0.1:8200"
}

auto_auth {
  method "approle" {
    config = {
      role_id_file_path                   = "./role_id"
      secret_id_file_path                 = "./secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "./vault-token"
    }
  }
}

template {
  source      = "./pg.env.ctmpl"
  destination = "./pg.env"
  # Opcional: reiniciar o recargar tu servicio al rotar la clave
  # command   = "echo 'Clave rotada!' >> rotation.log"
}

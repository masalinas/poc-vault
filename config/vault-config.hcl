ui = true
disable_mlock = true

storage "raft" {
  path    = "/vault/file"
  node_id = "vault-node-1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1 # Solo para entornos locales/pruebas. En producción usa TLS.
}

api_addr     = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"

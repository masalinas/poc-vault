# Description
To automatically rotate the password for an existing user in PostgreSQL, you use Vault’s Database engine in "Static Role" mode. Vault will update the password in PostgreSQL according to a schedule you define, and Vault Agent will detect this rotation and update your application’s configuration file—all without any manual intervention.

## Steps:

- **STEP01**: Set up a test PostgreSQL instance with the user to be rotated
Verification: `docker exec -i vault-pg psql -U postgres -c "\du"` 

should show `app_user` in the list of roles.

```shell
$ docker exec -i pg-poc-vault psql -U postgres -c "\du"
                             List of roles
 Role name |                         Attributes                         
-----------+------------------------------------------------------------
 app_user  | 
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS
```

- **STEP02**: Configure the database engine and the Static Role in Vault
Enable the engine, connect Vault to PostgreSQL, and configure rotation every 60 seconds so you can observe it in real time:

```shell
# 1. Enable the database engine
$ vault secrets enable database
Success! Enabled the database secrets engine at: database/

# 2. Register the connection to PostgreSQL
# Note: If Vault is running in Docker, use your host's IP address or the container name (if on the same Docker network)
# connection_url="postgresql://{{username}}:{{password}}@host.docker.internal:5432/postgres?sslmode=disable" \

$ vault write database/config/mi-postgres \
    plugin_name=postgresql-database-plugin \
    allowed_roles="pg-static-role" \
    connection_url="postgresql://{{username}}:{{password}}@vault-pg:5432/postgres?sslmode=disable" \
    username="postgres" \
    password="rootpassword"
Success! Data written to: database/config/mi-postgres

# 3. Create the Static Role that will rotate the 'app_user' key every 60s
$ vault write database/static-roles/pg-static-role \
    db_name=mi-postgres \
    username="app_user" \
    rotation_period="60s"
```
Success! Data written to: database/static-roles/pg-static-role

- **STEP03**: Create the policy and the AppRole for the agent
Grant the agent permission solely to read the credentials for that static role:

```shell
$ vault policy write pg-agent-policy - <<EOF
path "database/static-creds/pg-static-role" {
  capabilities = ["read"]
}
EOF
Success! Uploaded policy: pg-agent-policy

# Si aún no tienes AppRole habilitado: vault auth enable approle
$ vault auth enable approle

$ vault write auth/approle/role/pg-agent-role \
    secret_id_ttl=24h \
    token_ttl=1h \
    token_max_ttl=4h \
    token_policies="pg-agent-policy"
Success! Data written to: auth/approle/role/pg-agent-role

# Extraer role_id y secret_id a ficheros locales para el agente
$ cd services/vault-agent/database

$ vault read -field=role_id auth/approle/role/pg-agent-role/role-id > role_id
$ vault write -f -field=secret_id auth/approle/role/pg-agent-role/secret-id > secret_id
```

- **STEP04**: Creating the Vault Agent template and configuration
Create `pg.env.ctmpl` (note that `.Data.username` is used here instead of `.Data.data`, unlike in KV v2):

```shell
{{- with secret "database/static-creds/pg-static-role" }}
PG_USER={{ .Data.username }}
PG_PASSWORD={{ .Data.password }}
{{- end }}
```

- **STEP05**: Create `agent-config.hcl`
```shell
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
```

- **STEP05**: Start the agent and verify rotation in real time

Run the agent in a terminal:

```shell
$ vault agent -config=agent-config.hcl
==> Vault Agent started! Log data will stream in below:

==> Vault Agent configuration:

           Api Address 1: http://bufconn
                     Cgo: disabled
               Log Level: 
                 Version: Vault v2.2.2, built 2026-11-11T13:53:02Z
             Version Sha: c56e7e670bd8c79104c27b6c10138226538a6db2

2026-11-20T12:27:27.482+0100 [INFO]  agent.sink.file: creating file sink
2026-11-20T12:27:27.482+0100 [INFO]  agent.sink.file: file sink configured: path=./vault-token mode=-rw-r----- owner=1000 group=1000
2026-11-20T12:27:27.484+0100 [INFO]  agent.sink.server: starting sink server
2026-11-20T12:27:27.484+0100 [INFO]  agent.exec.server: starting exec server
2026-11-20T12:27:27.484+0100 [INFO]  agent.exec.server: no env templates or exec config, exiting
2026-11-20T12:27:27.484+0100 [INFO]  agent.template.server: starting template server
2026-11-20T12:27:27.484+0100 [INFO]  agent.auth.handler: starting auth handler
2026-11-20T12:27:27.484+0100 [INFO]  agent: (runner) creating new runner (dry: false, once: false)
2026-11-20T12:27:27.484+0100 [INFO]  agent.auth.handler: authenticating
2026-11-20T12:27:27.486+0100 [INFO]  agent: (runner) creating watcher
2026-11-20T12:27:27.499+0100 [INFO]  agent.auth.handler: authentication successful, sending token to sinks
2026-11-20T12:27:27.499+0100 [INFO]  agent.auth.handler: starting renewal process
2026-11-20T12:27:27.499+0100 [INFO]  agent.template.server: template server received new token
2026-11-20T12:27:27.499+0100 [INFO]  agent: (runner) stopping
2026-11-20T12:27:27.499+0100 [INFO]  agent: (runner) creating new runner (dry: false, once: false)
2026-11-20T12:27:27.499+0100 [INFO]  agent.sink.file: token written: path=./vault-token
2026-11-20T12:27:27.499+0100 [INFO]  agent: (runner) creating watcher
2026-11-20T12:27:27.500+0100 [INFO]  agent: (runner) starting
2026-11-20T12:27:27.505+0100 [INFO]  agent.auth.handler: renewed auth token
2026-11-20T12:27:27.505+0100 [INFO]  agent: (runner) rendered "./pg.env.ctmpl" => "./pg.env
```

In another terminal, observe how the file changes automatically every minute:

```shell
$ watch -n 5 cat pg.env
Cada 5,0s: cat pg.env                                                                                                                                                miguel-Inspiron-5502: Thu Nov 19 13:57:25 2026


PG_USER=app_user
PG_PASSWORD=gUc-1XXJ1N3EtRiJYEhi
```

Verification: After 60 seconds, PG_PASSWORD will change in pg.env, and you will be able to connect to PostgreSQL using this new password (while the previous one will stop working immediately).
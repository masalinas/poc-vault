# Description
A simple AppRole sample using Vault Server and Vault Agent

## Steps

- **STEP01**: Setting up the secret, the policy, and the AppRole in Vault

```shell
# 1. Guardar un secreto de prueba en KV v2
$ vault kv put secret/mi-app db_user="admin_local" db_pass="S3cr3t0_2026"
=== Secret Path ===
secret/data/mi-app

======= Metadata =======
Key                Value
---                -----
created_time       2026-11-19T11:48:34.309166699Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            2

# 2. Crear una política de solo lectura para ese secreto
$ vault policy write mi-app-policy - <<EOF
path "secret/data/mi-app" {
  capabilities = ["read"]
}
EOF
Success! Uploaded policy: mi-app-policy

# 3. Habilitar AppRole y crear el rol asociado a la política
$ vault auth enable approle
Success! Enabled approle auth method at: approle/

$ vault write auth/approle/role/mi-app-role \
    secret_id_ttl=24h \
    token_ttl=1h \
    token_max_ttl=4h \
    token_policies="mi-app-policy"
Success! Data written to: auth/approle/role/mi-app-role

# 4. Extraer role_id y secret_id a ficheros locales para el agente
$ vault read -field=role_id auth/approle/role/mi-app-role/role-id > role_id.txt

$ vault write -f -field=secret_id auth/approle/role/mi-app-role/secret-id > secret_id.txt
```

- **STEP02**: Create the template (app.env.ctmpl)
This template tells the agent which path to read and the format in which to write the final file:

```shell
{{- with secret "secret/data/mi-app" }}
DB_USER={{ .Data.data.db_user }}
DB_PASSWORD={{ .Data.data.db_pass }}
{{- end }}
```

- **STEP03**: Create the agent configuration (agent-config.hcl)
```shell
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
      path = "./vault-token-via-agent"
    }
  }
}

template {
  source      = "./app.env.ctmpl"
  destination = "./app.env"
  # Optional: command to execute each time the secret changes
  # command   = "systemctl reload my-app"
}
```

(Note: In a production environment, `remove_secret_id_file_after_reading` should be set to `true` for security reasons; here, it is set to `false` so 
that you can restart the PoC without having to regenerate the `secret_id` each time.)

- **STEP04**: Start the agent and verify
Launch the agent using the same Vault CLI binary:

```shell
$ vault agent -config=agent-config.hcl
==> Vault Agent started! Log data will stream in below:

==> Vault Agent configuration:

           Api Address 1: http://bufconn
                     Cgo: disabled
               Log Level: 
                 Version: Vault v2.2.2, built 2026-11-11T13:53:02Z
             Version Sha: c56e7e670bd8c79104c27b6c10138226538a6db2

2026-11-19T13:00:37.189+0100 [INFO]  agent.sink.file: creating file sink
2026-11-19T13:00:37.189+0100 [INFO]  agent.sink.file: file sink configured: path=./vault-token-via-agent mode=-rw-r----- owner=1000 group=1000
2026-11-19T13:00:37.191+0100 [INFO]  agent.sink.server: starting sink server
2026-11-19T13:00:37.191+0100 [INFO]  agent.exec.server: starting exec server
2026-11-19T13:00:37.191+0100 [INFO]  agent.exec.server: no env templates or exec config, exiting
2026-11-19T13:00:37.191+0100 [INFO]  agent.auth.handler: starting auth handler
2026-11-19T13:00:37.191+0100 [INFO]  agent.auth.handler: authenticating
2026-11-19T13:00:37.191+0100 [INFO]  agent.template.server: starting template server
2026-11-19T13:00:37.191+0100 [INFO]  agent: (runner) creating new runner (dry: false, once: false)
2026-11-19T13:00:37.192+0100 [INFO]  agent: (runner) creating watcher
2026-11-19T13:00:37.205+0100 [INFO]  agent.auth.handler: authentication successful, sending token to sinks
2026-11-19T13:00:37.205+0100 [INFO]  agent.auth.handler: starting renewal process
2026-11-19T13:00:37.205+0100 [INFO]  agent.template.server: template server received new token
2026-11-19T13:00:37.205+0100 [INFO]  agent.sink.file: token written: path=./vault-token-via-agent
2026-11-19T13:00:37.205+0100 [INFO]  agent: (runner) stopping
2026-11-19T13:00:37.205+0100 [INFO]  agent: (runner) creating new runner (dry: false, once: false)
2026-11-19T13:00:37.206+0100 [INFO]  agent: (runner) creating watcher
2026-11-19T13:00:37.206+0100 [INFO]  agent: (runner) starting
2026-11-19T13:00:37.209+0100 [INFO]  agent.auth.handler: renewed auth token
2026-11-19T13:00:37.211+0100 [INFO]  agent: (runner) rendered "./app.env.ctmpl" => "./app.env"
```

- **STEP05**: Some tests using your Vault agent
If, while the agent is still running, you update the secret using `vault kv put secret/mi-app db_user="admin_local" db_pass="NuevaClave99"`, the agent will automatically detect the change and update `app.env` without you needing to take any further action.

```shell
vault kv put secret/mi-app db_user="admin_local" db_pass="NuevaClave99"
=== Secret Path ===
secret/data/mi-app

======= Metadata =======
Key                Value
---                -----
created_time       2026-11-19T12:04:43.847716105Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            3
```

# Description
a mTLS sample 

## Steps

- **STEP01**: Create PKI roles and policies 

```shell
# export Vault Server url
export VAULT_ADDR='http://127.0.0.1:8200'

# 1. Habilitar PKI y generar una CA raíz interna
$ vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/

$ vault secrets tune -max-lease-ttl=8760h pki
Success! Tuned the secrets engine at: pki/

$ vault write pki/root/generate/internal \
    common_name="mi-ca-local.internal" \
    ttl=8760h
WARNING! The following warnings were returned from Vault:

  * This mount hasn't configured any authority information access (AIA)
  fields; this may make it harder for systems to find missing certificates
  in the chain or to validate revocation status of certificates. Consider
  updating /config/urls or the newly generated issuer with this information.

Key              Value
---              -----
certificate      -----BEGIN CERTIFICATE-----
MIIDUjCCAjqgAwIBAgIUDjzTU9BSqO/yIKg0juGPytGgf+YwDQYJKoZIhvcNAQEL
BQAwHzEdMBsGA1UEAxMUbWktY2EtbG9jYWwuaW50ZXJuYWwwHhcNMjYxMTIwMTIy
MzQ4WhcNMjYxMjIyMTIyNDE4WjAfMR0wGwYDVQQDExRtaS1jYS1sb2NhbC5pbnRl
cm5hbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM8w4qrDrpM+sEDd
ynw0DJ9HPsLD7uY8J5JF1vpEH9ibC0H6DbM5iSszONXDRheOSoeaFX/6gAcTnK4N
C9zwe4skZHM0CVid8uu9YlNsVCLyLMSJWQmIYohFtLunW3uTvTKVwuUh9efO7gdL
ZqHcXhfzkkKnuT2hbt/QVCQ99DsqaGwJHo2XENBgxDZ3qcjSmbFalnK6uwV+22nc
86QUl4DjYAMIXU+VSY7rRP2QAhReojTkqay3GKP4DlH5wujTubCRZ2z4UxEKyB2f
qp+2+4PsPVJlkXVGS0UNaBmKwpn0zj+5jZ9fWB6EFpvbpeFmFGy87SABPX6A9Xwo
v8vabmECAwEAAaOBhTCBgjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB
/zAdBgNVHQ4EFgQUic4sYk0I58o2/uTdsKbDVcCwD3cwHwYDVR0jBBgwFoAUic4s
Yk0I58o2/uTdsKbDVcCwD3cwHwYDVR0RBBgwFoIUbWktY2EtbG9jYWwuaW50ZXJu
YWwwDQYJKoZIhvcNAQELBQADggEBAH/645Ma0mHhDmJ4Y9J7T90PfhBGYMEoGDyj
21PO6+PR+aDPIugImMsBRy9qjeNA7Hmcp/b5CXGr0GS3P6nYt/Kz1OZocoUgXHsz
OiAypsUmsAu6JwEqTJFMSnQrzIYpXySpq2y7dK4cKQJHmmiC6GEiO34fQkf9P1SJ
LQl8730B5bevd8CZ5rkEJyhr9JI6DnamIh+tbREQi8LYZ4QFSguKpR3iEOsEdDfo
pCr8qCL5UoePkwF+FBvH4BSJ25yyWFCexkj+a6yYBf57YaEO7zAMEqEdSexQDckb
1r7KUQOhdZuV8LvgBxttEUOFY40duSiN/bX1IW6XEOrmQB/sIy0=
-----END CERTIFICATE-----
expiration       1797942258
issuer_id        45f01414-e9cb-2b59-dc8b-77efe4a4b54d
issuer_name      n/a
issuing_ca       -----BEGIN CERTIFICATE-----
MIIDUjCCAjqgAwIBAgIUDjzTU9BSqO/yIKg0juGPytGgf+YwDQYJKoZIhvcNAQEL
BQAwHzEdMBsGA1UEAxMUbWktY2EtbG9jYWwuaW50ZXJuYWwwHhcNMjYxMTIwMTIy
MzQ4WhcNMjYxMjIyMTIyNDE4WjAfMR0wGwYDVQQDExRtaS1jYS1sb2NhbC5pbnRl
cm5hbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM8w4qrDrpM+sEDd
ynw0DJ9HPsLD7uY8J5JF1vpEH9ibC0H6DbM5iSszONXDRheOSoeaFX/6gAcTnK4N
C9zwe4skZHM0CVid8uu9YlNsVCLyLMSJWQmIYohFtLunW3uTvTKVwuUh9efO7gdL
ZqHcXhfzkkKnuT2hbt/QVCQ99DsqaGwJHo2XENBgxDZ3qcjSmbFalnK6uwV+22nc
86QUl4DjYAMIXU+VSY7rRP2QAhReojTkqay3GKP4DlH5wujTubCRZ2z4UxEKyB2f
qp+2+4PsPVJlkXVGS0UNaBmKwpn0zj+5jZ9fWB6EFpvbpeFmFGy87SABPX6A9Xwo
v8vabmECAwEAAaOBhTCBgjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB
/zAdBgNVHQ4EFgQUic4sYk0I58o2/uTdsKbDVcCwD3cwHwYDVR0jBBgwFoAUic4s
Yk0I58o2/uTdsKbDVcCwD3cwHwYDVR0RBBgwFoIUbWktY2EtbG9jYWwuaW50ZXJu
YWwwDQYJKoZIhvcNAQELBQADggEBAH/645Ma0mHhDmJ4Y9J7T90PfhBGYMEoGDyj
21PO6+PR+aDPIugImMsBRy9qjeNA7Hmcp/b5CXGr0GS3P6nYt/Kz1OZocoUgXHsz
OiAypsUmsAu6JwEqTJFMSnQrzIYpXySpq2y7dK4cKQJHmmiC6GEiO34fQkf9P1SJ
LQl8730B5bevd8CZ5rkEJyhr9JI6DnamIh+tbREQi8LYZ4QFSguKpR3iEOsEdDfo
pCr8qCL5UoePkwF+FBvH4BSJ25yyWFCexkj+a6yYBf57YaEO7zAMEqEdSexQDckb
1r7KUQOhdZuV8LvgBxttEUOFY40duSiN/bX1IW6XEOrmQB/sIy0=
-----END CERTIFICATE-----
key_id           780213af-1a43-ca2f-e882-d80b20588718
key_name         n/a
serial_number    0e:3c:d3:53:d0:52:a8:ef:f2:20:a8:34:8e:e1:8f:ca:d1:a0:7f:e6

# 2. Crear un rol PKI que permita emitir certificados para localhost y clientes
$ vault write pki/roles/nginx-mtls \
    allowed_domains="localhost,mi-ca-local.internal" \
    allow_subdomains=true \
    allow_localhost=true \
    allow_ip_sans=true \
    max_ttl="24h"
Key                                   Value
---                                   -----
allow_any_name                        false
allow_bare_domains                    false
allow_glob_domains                    false
allow_ip_sans                         true
allow_localhost                       true
allow_subdomains                      true
allow_token_displayname               false
allow_wildcard_certificates           true
allowed_domains                       [localhost mi-ca-local.internal]
allowed_domains_template              false
allowed_other_sans                    []
allowed_serial_numbers                []
allowed_uri_sans                      []
allowed_uri_sans_template             false
allowed_user_ids                      []
basic_constraints_valid_for_non_ca    false
client_flag                           true
cn_validations                        [email hostname]
code_signing_flag                     false
country                               []
csr_extra_names_oids                  []
email_protection_flag                 false
enforce_hostnames                     true
ext_key_usage                         []
ext_key_usage_oids                    []
generate_lease                        false
issuer_ref                            default
key_bits                              2048
key_type                              rsa
key_usage                             [DigitalSignature KeyAgreement KeyEncipherment]
locality                              []
max_ttl                               24h
no_store                              false
not_after                             n/a
not_before_duration                   30s
organization                          []
ou                                    []
parameter_set                         n/a
policy_identifiers                    []
postal_code                           []
province                              []
require_cn                            true
serial_number_source                  json-csr
server_flag                           true
signature_bits                        256
street_address                        []
ttl                                   0s
use_csr_common_name                   true
use_csr_sans                          true
use_pss                               false

# 3. Crear política que permita emitir certificados con ese rol
$ vault policy write nginx-pki-policy - <<EOF
path "pki/issue/nginx-mtls" {
  capabilities = ["create", "update"]
}
EOF
Success! Uploaded policy: nginx-pki-policy

# 4. If not is enable: Habilitar AppRole para que Vault Agent se autentique automáticamente
$ vault auth enable approle

$ vault write auth/approle/role/nginx-agent \
    token_policies="nginx-pki-policy" \
    token_ttl=1h \
    token_max_ttl=4h
Success! Data written to: auth/approle/role/nginx-agent

# 5. Guardar role_id y secret_id en disco para Vault Agent
$ vault read -field=role_id auth/approle/role/nginx-agent/role-id > role_id
$ vault write -f -field=secret_id auth/approle/role/nginx-agent/secret-id > secret_id
```

- **STEP02**: Issue a client certificate and key from Vault and test GET response

```shell
$ vault write -format=json pki/issue/nginx-mtls common_name="client.localhost" ttl="24h" > client_cert.json
$ jq -r '.data.certificate' client_cert.json > client.crt
$ jq -r '.data.private_key' client_cert.json > client.key
```

Verification: Run ls -lh `client.crt` `client.key` and confirm both files are non-empty.

Test the mTLS endpoint
```shell
$ curl --cacert ./services/vault-agent/mtls/certs/ca.crt \
     --cert client.crt \
     --key client.key \
     https://localhost:8443
mTLS OK! Cliente autenticado: CN=client.localhost
```

Verification: Nginx returns 200 OK and your page content instead of 400 Bad Request.
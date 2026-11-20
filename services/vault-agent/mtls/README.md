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
MIIDUjCCAjqgAwIBAgIUVcjdmyyPRpj7k2AszZKmBNc7hYowDQYJKoZIhvcNAQEL
BQAwHzEdMBsGA1UEAxMUbWktY2EtbG9jYWwuaW50ZXJuYWwwHhcNMjYxMTE5MTYz
NzQ2WhcNMjcxMTE5MTYzODE2WjAfMR0wGwYDVQQDExRtaS1jYS1sb2NhbC5pbnRl
cm5hbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL5GVNMlCmtqO2D7
fOAsy6h3vkiDlniPWOOPUeMdHvJGqiIGgFx7FtIj4edlDWpjkvzX4jGprwl4J9Z0
5uwb07mUpW2Ae0MamOq7XBSUaqGdIydunwPUtIP/0EDuI5n0r9JQBioljCQFgyhW
4qKyZ+yzBeHvlOXL4RhlutgiRBFj3pg4JfzaghyyETkjBVlQLXPe2uTOvntUC3We
FWfiQ5D/SB97lBHcAMBg2xXW9W0/YvoQi+jOOOtFIYkCvmJW9duQul25ipkKzKuS
PLVUm7EhcvAc3PE65DYRM3s9hsdzucEPhvcuHmyP5Vl1JuB2hDouXoHa36HZM09C
nE3PhSECAwEAAaOBhTCBgjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB
/zAdBgNVHQ4EFgQUKvSHicdzj+taCBibKcZkzxANiS8wHwYDVR0jBBgwFoAUKvSH
icdzj+taCBibKcZkzxANiS8wHwYDVR0RBBgwFoIUbWktY2EtbG9jYWwuaW50ZXJu
YWwwDQYJKoZIhvcNAQELBQADggEBAC4NKAipWMZzUy5cKtJgbx2iQQVuKliomvuu
eUexn1NyOfrpSTpRrWS3fDhYSJJMcwHQkLUWPPOzulNNHqzcEOTKcE8X4cMDhuJx
rbv+287pl3shE32oxrUYfcrF00UJBJQZMThKJbectdd3ApQ5euEC+bw6Y28i9AHS
uf4D1zrgNwEEfPGUcIILaCe/cQWVH3TB5HGn9WsygKerof6lz987TnlCaLu3le4f
b50kxs8Lw0sHNhwjYrhVHF3Tzdm5/0WotGYb0biedre+xnPvBmUglIqMlqwp3v8n
9YZfuFxX1vQc+MNfGtOBn4A8q/V5r/COVHNrthedVQmlvb1dqaY=
-----END CERTIFICATE-----
expiration       1826642296
issuer_id        3fec4205-02ba-6edb-d29b-b4ed28fe4863
issuer_name      n/a
issuing_ca       -----BEGIN CERTIFICATE-----
MIIDUjCCAjqgAwIBAgIUVcjdmyyPRpj7k2AszZKmBNc7hYowDQYJKoZIhvcNAQEL
BQAwHzEdMBsGA1UEAxMUbWktY2EtbG9jYWwuaW50ZXJuYWwwHhcNMjYxMTE5MTYz
NzQ2WhcNMjcxMTE5MTYzODE2WjAfMR0wGwYDVQQDExRtaS1jYS1sb2NhbC5pbnRl
cm5hbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL5GVNMlCmtqO2D7
fOAsy6h3vkiDlniPWOOPUeMdHvJGqiIGgFx7FtIj4edlDWpjkvzX4jGprwl4J9Z0
5uwb07mUpW2Ae0MamOq7XBSUaqGdIydunwPUtIP/0EDuI5n0r9JQBioljCQFgyhW
4qKyZ+yzBeHvlOXL4RhlutgiRBFj3pg4JfzaghyyETkjBVlQLXPe2uTOvntUC3We
FWfiQ5D/SB97lBHcAMBg2xXW9W0/YvoQi+jOOOtFIYkCvmJW9duQul25ipkKzKuS
PLVUm7EhcvAc3PE65DYRM3s9hsdzucEPhvcuHmyP5Vl1JuB2hDouXoHa36HZM09C
nE3PhSECAwEAAaOBhTCBgjAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB
/zAdBgNVHQ4EFgQUKvSHicdzj+taCBibKcZkzxANiS8wHwYDVR0jBBgwFoAUKvSH
icdzj+taCBibKcZkzxANiS8wHwYDVR0RBBgwFoIUbWktY2EtbG9jYWwuaW50ZXJu
YWwwDQYJKoZIhvcNAQELBQADggEBAC4NKAipWMZzUy5cKtJgbx2iQQVuKliomvuu
eUexn1NyOfrpSTpRrWS3fDhYSJJMcwHQkLUWPPOzulNNHqzcEOTKcE8X4cMDhuJx
rbv+287pl3shE32oxrUYfcrF00UJBJQZMThKJbectdd3ApQ5euEC+bw6Y28i9AHS
uf4D1zrgNwEEfPGUcIILaCe/cQWVH3TB5HGn9WsygKerof6lz987TnlCaLu3le4f
b50kxs8Lw0sHNhwjYrhVHF3Tzdm5/0WotGYb0biedre+xnPvBmUglIqMlqwp3v8n
9YZfuFxX1vQc+MNfGtOBn4A8q/V5r/COVHNrthedVQmlvb1dqaY=
-----END CERTIFICATE-----
key_id           d4f34859-b949-6a79-573b-4c0257f83af8
key_name         n/a
serial_number    55:c8:dd:9b:2c:8f:46:98:fb:93:60:2c:cd:92:a6:04:d7:3b:85:8a

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
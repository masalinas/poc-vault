# Description
Deploy a Vault Server and everal Vault samples using Vault Agents and Docker containers.

## Deploy Vault Server

- [Vault Server](./services/vault-server/README.md)

## Deploy Vault Samples

- [Vault Simple Sample](./services/vault-agent/simple/README.md): A kv secret Vault sample using KV Secret Engine to deploy a secret to be pulled by Vault Agent
- [Vault Database Sample](./services/vault-agent/database/README.md): A password PostgreSQL Database Vault sample using Database Secret Engine to be rotated and pulled by a Vault Agent
- [Vault mTLS Sample](./services/vault-agent/mtls/README.md): A mTLS Vault sample using a PKI Secret Engine to generate temporal dynamic certificates and pulled by a Vault Agent to be connect to a Nginx Web Server from a client like curl tool.

![Docker Services](./images/docker_services.png)
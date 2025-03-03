# Pull the latest PostgreSQL image
docker pull postgres:latest

# Run PostgreSQL container
docker run --name postgres-vault \
    -e POSTGRES_PASSWORD=rootpassword \
    -p 5432:5432 \
    -d postgres:latest

# Wait for PostgreSQL to start
Start-Sleep -Seconds 5

# Create vault admin user
docker exec postgres-vault psql -U postgres -c "CREATE USER vault WITH SUPERUSER PASSWORD 'vaultpass';"

# Start a Vault server in dev mode
vault server -dev

# Set the VAULT_ADDR environment variable
$env:VAULT_ADDR="http://127.0.0.1:8200"

# Enable the postgresql secrets engine on Vault
vault secrets enable database

# Configure the postgresql secrets engine
vault write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="readonly" \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/postgres" \
    username="vault" \
    password="vaultpass" \
    password_authentication="scram-sha-256"

# Create a role named "readonly" for the postgresql secrets engine
vault write database/roles/readonly \
    db_name=postgresql \
    creation_statements=$(Get-Content .\readonly.sql) \
    default_ttl="1h" \
    max_ttl="24h"

# Create a policy named "readonly" to read the "readonly" role
vault policy write readonly .\readonly-policy.hcl

# Create a token with the "readonly" policy
vault token create -policy=readonly

# Login with the token
vault login TOKEN

# Generate a new credential
vault read database/creds/readonly


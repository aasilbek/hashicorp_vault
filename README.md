# Install required tools

```bash
{
    sudo apt update
    sudo apt-get install postgresql nginx certbot python3-certbot-nginx docker.io make docker-compose -y
    
}
```
```bash
    sudo gpasswd -a $USER docker
    newgrp docker
```

## Setup Postgres
### Database credentials must be same as in docker-compose file.
```bash
CREATE DATABASE vault;
CREATE USER vault WITH PASSWORD 'vaultSecretPassword';
ALTER ROLE vault SET client_encoding TO 'utf8';
ALTER ROLE vault SET default_transaction_isolation TO 'read committed';
ALTER ROLE vault SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE vault TO vault;
```

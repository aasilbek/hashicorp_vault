# Setup HashiCorp Vault
Copy this repo to your server or make similar structure.
```bash
git clone https://github.com/aasilbek/vault.git
```
Change credentials in config/vault.hcl file. Later you will need them while creating database.

## Install required tools

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
### Change user to postgres and run psql
```bash
su postgres
psql
```
### Database credentials must be same as in config/vault.hcl.
```bash
CREATE DATABASE vault;
CREATE USER vault WITH PASSWORD 'vaultSecretPassword';
ALTER ROLE vault SET client_encoding TO 'utf8';
ALTER ROLE vault SET default_transaction_isolation TO 'read committed';
ALTER ROLE vault SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE vault TO vault;

```
Log out from postgres user and use vault user
```bash
 psql -U vault -d vault -h localhost
```
### Create database tables
```bash
CREATE TABLE vault_kv_store (
  parent_path TEXT COLLATE "C" NOT NULL,
  path        TEXT COLLATE "C",
  key         TEXT COLLATE "C",
  value       BYTEA,
  CONSTRAINT pkey PRIMARY KEY (path, key)
);

CREATE INDEX parent_path_idx ON vault_kv_store (parent_path);

CREATE TABLE vault_ha_locks (
  ha_key                                      TEXT COLLATE "C" NOT NULL,
  ha_identity                                 TEXT COLLATE "C" NOT NULL,
  ha_value                                    TEXT COLLATE "C",
  valid_until                                 TIMESTAMP WITH TIME ZONE NOT NULL,
  CONSTRAINT ha_key PRIMARY KEY (ha_key)
);
```

### Change database configs.
Find file path with 
```bash
sudo find / -name "postgresql.conf"
sudo find / -name pg_hba.conf
```
Change postgresql.conf file . Find  listen_addresses variable and set it to * </br>
listen_addresses = '*' </br>

Change pg_hba.conf file . Add this to the end of file
```bash
host    all             all              0.0.0.0/0              md5
host    all             all              ::/0                   md5
```

Restart postgres service
```bash
sudo systemctl restart postgresql
```

## Run docker-compose command to start container
```bash
docker-compose up -d
```
Initialize vault and save output . 
```bash
docker exec -it vault_container vault operator init
```

## Setup Nginx. Use nginx_example file.
```bash
sudo vim /etc/nginx/sites-available/vault
```
Check nginx file
```bash
sudo nginx -t
```
If everything is ok restart nginx serivce
```bash
sudo systemctl restart nginx
```

## Get ssl certificate with certbot
```bash
certbot
```
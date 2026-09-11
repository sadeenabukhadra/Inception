# Inception — Developer Documentation

## Overview

This document explains how to set up, build, run and manage the Inception infrastructure from a development environment.

The infrastructure is built with Docker Compose and contains:

```text
NGINX
WordPress + PHP-FPM
MariaDB
```

Each service has its own Dockerfile and container.

---

# 1. Prerequisites

The project must be executed inside a Virtual Machine.

Install the required tools:

* Docker
* Docker Compose
* Make
* Git

Verify the installation:

```bash
docker --version
```

```bash
docker compose version
```

```bash
make --version
```

```bash
git --version
```

---

# 2. Clone the Repository

Clone the repository:

```bash
git clone <repository-url>
```

Enter the project:

```bash
cd inception
```

---

# 3. Project Configuration

The project configuration is located in:

```text
srcs/.env
```

The `.env` file contains non-secret configuration values.

Example:

```env
DOMAIN_NAME=sabu-kha.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=<database-user>
```

Sensitive values such as passwords should not be stored directly in `.env`.

---

# 4. Docker Secrets

The project uses Docker secrets for confidential credentials.

The secrets directory contains files such as:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
└── credentials.txt
```

Each secret file contains the corresponding value.

Example:

```bash
printf '%s' 'your-password' > secrets/db_password.txt
```

The secret files must remain local and must be ignored by Git.

Check the Git status before committing:

```bash
git status
```

Make sure that no confidential credentials are staged.

---

# 5. Domain Configuration

The project uses:

```text
sabu-kha.42.fr
```

The domain must resolve to the Virtual Machine's IP address.

For local development, configure the host resolution accordingly.

Example:

```text
<VM_IP> sabu-kha.42.fr
```

Verify the resolution:

```bash
getent hosts sabu-kha.42.fr
```

---

# 6. Docker Compose

The main orchestration file is:

```text
srcs/docker-compose.yml
```

Docker Compose defines:

* Services
* Build contexts
* Dockerfiles
* Environment variables
* Secrets
* Networks
* Volumes
* Restart policies
* Dependencies

The three main services are:

```text
nginx
wordpress
mariadb
```

---

# 7. Building the Images

From the project root:

```bash
make
```

The Makefile is responsible for building and starting the infrastructure.

The images are built locally from the project's Dockerfiles.

No ready-made application images are used.

To rebuild the images manually:

```bash
cd srcs
docker compose build
```

To force a complete rebuild:

```bash
docker compose build --no-cache
```

---

# 8. Starting the Stack

Start the infrastructure in detached mode:

```bash
cd srcs
docker compose up -d
```

Build and start at the same time:

```bash
docker compose up -d --build
```

Check the services:

```bash
docker compose ps
```

---

# 9. Stopping the Stack

Stop the running containers:

```bash
docker compose down
```

This removes the containers and network created by Compose but keeps the named volumes unless they are explicitly removed.

---

# 10. Container Management

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

Inspect a container:

```bash
docker inspect <container>
```

Open a shell inside a running container when required for debugging:

```bash
docker exec -it <container> sh
```

For example:

```bash
docker exec -it mariadb sh
```

---

# 11. Logs

View all logs:

```bash
docker compose logs
```

View a specific service:

```bash
docker compose logs nginx
```

```bash
docker compose logs wordpress
```

```bash
docker compose logs mariadb
```

Follow logs:

```bash
docker compose logs -f
```

Follow one service:

```bash
docker compose logs -f nginx
```

---

# 12. Docker Network

The containers communicate through a dedicated Docker network.

List networks:

```bash
docker network ls
```

Inspect the project network:

```bash
docker network inspect <network_name>
```

The expected communication is:

```text
nginx
  │
  ▼
wordpress
  │
  ▼
mariadb
```

MariaDB does not need to be exposed to the host because WordPress can access it through the internal Docker network.

---

# 13. Docker Volumes

The project uses two named volumes for persistent data.

Typical purposes:

```text
Database volume
    ↓
MariaDB data

WordPress volume
    ↓
WordPress website files
```

List volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect <volume_name>
```

The project data is configured to persist under:

```text
/home/sabu-kha/data
```

on the host.

---

# 14. Data Persistence

Containers themselves are not the location for persistent application data.

If the MariaDB container is removed and recreated, the database should remain available because the database directory is stored in a named volume.

Similarly, WordPress website files are stored in a named volume.

Therefore:

```text
Container
   │
   ├── temporary container filesystem
   │
   └── named volume
             │
             ▼
       persistent data
```

Do not delete the volumes unless the intention is to completely reset the application data.

---

# 15. Resetting the Infrastructure

To stop and remove the containers:

```bash
docker compose down
```

To remove the containers and named volumes:

```bash
docker compose down -v
```

**Warning:** removing the volumes deletes the persistent database and WordPress data.

After removing the volumes, starting the stack again causes the services to initialize their data from scratch.

---

# 16. Rebuilding After Code Changes

When modifying a Dockerfile or installation logic:

```bash
docker compose up -d --build
```

If an old image or build cache is causing problems:

```bash
docker compose build --no-cache
```

Then:

```bash
docker compose up -d
```

---

# 17. Debugging Workflow

When a service fails, follow this order.

### Step 1 — Check container status

```bash
docker compose ps
```

### Step 2 — Check logs

```bash
docker compose logs <service>
```

### Step 3 — Inspect the container

```bash
docker inspect <container>
```

### Step 4 — Enter the container if necessary

```bash
docker exec -it <container> sh
```

### Step 5 — Check networking

```bash
docker network inspect <network_name>
```

### Step 6 — Check volumes

```bash
docker volume ls
```

```bash
docker volume inspect <volume_name>
```

---

# 18. Service-Specific Development

## MariaDB

Main files:

```text
requirements/mariadb/
├── Dockerfile
├── conf/
│   └── 50-server.cnf
└── tools/
    └── mariadb-init.sh
```

The Dockerfile builds the MariaDB image.

`50-server.cnf` contains MariaDB server configuration.

`mariadb-init.sh` initializes the database when required and reads sensitive credentials from Docker secrets.

---

## NGINX

Main files:

```text
requirements/nginx/
├── Dockerfile
├── conf/
│   └── nginx.conf
└── tools/
    └── nginx-init.sh
```

The NGINX configuration defines the HTTPS server and reverse-proxy behavior.

The container uses TLS 1.2/1.3 as required by the project.

---

## WordPress

Main files:

```text
requirements/wordpress/
├── Dockerfile
├── conf/
└── tools/
```

The WordPress container provides the WordPress application and PHP-FPM.

NGINX and MariaDB are kept in separate containers.

---

# 19. Makefile

The Makefile is located at:

```text
Makefile
```

Its purpose is to provide convenient commands for managing the entire infrastructure.

Typical commands include:

```bash
make
```

Build and start the project.

```bash
make down
```

Stop and remove the running containers/network.

Additional targets can be added for tasks such as:

```text
build
up
down
clean
fclean
re
```

The exact targets should match the project's Makefile implementation.

---

# 20. Security

Never commit:

```text
passwords
API keys
credentials
private keys
```

Check the repository before pushing:

```bash
git status
```

Sensitive files should be excluded through `.gitignore`.

The project specification explicitly prohibits storing credentials and passwords publicly in the repository.

---

# 21. Development Checklist

Before considering the environment ready, verify:

```text
[ ] Virtual Machine is running
[ ] Docker is installed
[ ] Docker Compose works
[ ] Make works
[ ] .env is configured
[ ] Secrets are configured
[ ] Domain resolves to the VM
[ ] Docker images build successfully
[ ] NGINX container is running
[ ] WordPress container is running
[ ] MariaDB container is running
[ ] Docker network exists
[ ] Both named volumes exist
[ ] HTTPS works on port 443
[ ] WordPress website loads
[ ] WordPress administration panel loads
[ ] Database persists after container recreation
[ ] No credentials are committed to Git
```

---

# 22. Final Architecture

```text
                    Virtual Machine
                         │
                         ▼
                 Docker Compose
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
     NGINX           WordPress          MariaDB
     TLS             PHP-FPM            Database
        │                │                │
        └────────┬───────┴────────────────┘
                 │
          Docker Network
                 │
        ┌────────┴────────┐
        ▼                 ▼
  WordPress Volume   Database Volume
        │                 │
        └────────┬────────┘
                 ▼
       /home/sabu-kha/data
```

The infrastructure therefore separates the reverse proxy, application and database into independent services while keeping communication internal and application data persistent.

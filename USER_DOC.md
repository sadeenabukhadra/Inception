# Inception — User Documentation

## Overview

This document explains how to use and operate the Inception infrastructure.

The stack provides a WordPress website through an HTTPS connection.

The infrastructure contains three services:

| Service   | Purpose                             |
| --------- | ----------------------------------- |
| NGINX     | HTTPS entry point and reverse proxy |
| WordPress | Website application                 |
| MariaDB   | WordPress database                  |

Only NGINX is accessible from outside the Docker network.

---

# Starting the Infrastructure

From the project root, run:

```bash
make
```

This builds the required Docker images and starts the services.

If the infrastructure is already built, the services can also be started with:

```bash
cd srcs
docker compose up -d
```

---

# Stopping the Infrastructure

To stop the containers:

```bash
make down
```

Or:

```bash
cd srcs
docker compose down
```

Stopping the containers does not remove the persistent named volumes.

Therefore, WordPress files and database data remain available when the services are started again.

---

# Accessing the Website

The website is available at:

```text
https://sabu-kha.42.fr
```

The connection uses HTTPS through NGINX.

The expected request flow is:

```text
Browser
   │
   │ HTTPS :443
   ▼
NGINX
   │
   ▼
WordPress
   │
   ▼
MariaDB
```

If the browser displays a certificate warning, this is expected when using a locally generated/self-signed certificate during development.

---

# WordPress Administration Panel

The WordPress administration interface is available at:

```text
https://sabu-kha.42.fr/wp-admin
```

Use the WordPress administrator credentials configured for the project.

The administrator username must not contain:

```text
admin
administrator
```

as required by the project specification.

---

# Credentials

Sensitive credentials are stored locally and must not be committed to Git.

The project uses the `secrets/` directory for confidential values.

Example:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
└── credentials.txt
```

### Database passwords

The MariaDB passwords are provided to the container through Docker secrets.

Inside the container, secrets are available under:

```text
/run/secrets/
```

For example:

```text
/run/secrets/db_password
/run/secrets/db_root_password
```

### WordPress credentials

WordPress administrator credentials are stored according to the project's local secret/configuration setup.

Do not publish passwords in:

* Git
* README files
* Dockerfiles
* Docker Compose files
* Screenshots
* Public repositories

---

# Checking the Services

To check the status of the containers:

```bash
docker compose ps
```

Expected services:

```text
nginx
wordpress
mariadb
```

All required services should be running.

---

# Checking Container Logs

To inspect all service logs:

```bash
docker compose logs
```

To inspect one service:

```bash
docker compose logs nginx
```

```bash
docker compose logs wordpress
```

```bash
docker compose logs mariadb
```

To follow logs in real time:

```bash
docker compose logs -f
```

---

# Checking the Website

A basic HTTPS test can be performed with:

```bash
curl -k -i https://sabu-kha.42.fr/
```

A successful response should indicate that NGINX is reachable and the request is being handled by the WordPress infrastructure.

---

# Checking the Containers

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

If a container is not running, inspect its logs:

```bash
docker compose logs <service>
```

For example:

```bash
docker compose logs nginx
```

---

# Persistent Data

The project uses two Docker named volumes.

They store:

1. MariaDB database data
2. WordPress website files

The data is stored on the host under:

```text
/home/sabu-kha/data
```

The data remains persistent when containers are stopped or recreated.

To list Docker volumes:

```bash
docker volume ls
```

To inspect a volume:

```bash
docker volume inspect <volume_name>
```

---

# Basic Troubleshooting

## Website does not load

Check:

```bash
docker compose ps
```

Then check NGINX:

```bash
docker compose logs nginx
```

Check that the domain resolves to the VM:

```bash
getent hosts sabu-kha.42.fr
```

Check HTTPS:

```bash
curl -k -i https://sabu-kha.42.fr/
```

---

## WordPress is not working

Check the WordPress container:

```bash
docker compose logs wordpress
```

Then check whether MariaDB is running:

```bash
docker compose ps mariadb
```

Check MariaDB logs:

```bash
docker compose logs mariadb
```

---

## Database connection problems

Check:

```bash
docker compose logs mariadb
```

Verify that the MariaDB container is running:

```bash
docker compose ps mariadb
```

The WordPress container communicates with MariaDB through the Docker network rather than through a host-exposed database port.

---

# Useful Commands

| Task            | Command                  |
| --------------- | ------------------------ |
| Start stack     | `make`                   |
| Stop stack      | `make down`              |
| List containers | `docker compose ps`      |
| View logs       | `docker compose logs`    |
| Follow logs     | `docker compose logs -f` |
| List volumes    | `docker volume ls`       |
| List networks   | `docker network ls`      |
| List containers | `docker ps -a`           |

---

# Security Notes

Do not expose MariaDB directly to the Internet.

Do not publish passwords or credentials.

The intended architecture is:

```text
Internet
   │
   ▼
HTTPS :443
   │
   ▼
 NGINX
   │
   ▼
WordPress
   │
   ▼
MariaDB
```

NGINX is the only external entry point.

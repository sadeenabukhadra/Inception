*This activity has been created as part of the 42 curriculum by sadeenabukhadra.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal of this activity is to build a small infrastructure using Docker and Docker Compose inside a Virtual Machine.

The infrastructure is composed of three services:

* **NGINX** — the only public entry point and HTTPS reverse proxy.
* **WordPress + PHP-FPM** — the web application.
* **MariaDB** — the database used by WordPress.

Each service runs inside its own dedicated Docker container. The containers communicate through a private Docker network, while persistent data is stored using Docker named volumes.

The project also demonstrates the use of:

* Dockerfiles
* Docker Compose
* Docker networks
* Docker named volumes
* Environment variables
* Docker secrets
* TLS/HTTPS
* Virtual machines
* Persistent storage
* Container restart policies

The project is designed so that NGINX is the only service directly exposed to the outside through port `443`. Requests are securely forwarded to WordPress, while WordPress communicates with MariaDB through the internal Docker network.

---

## Architecture

The infrastructure consists of three containers connected through a Docker network.

```text
                         HTTPS
                          │
                          │ Port 443
                          ▼
                  ┌─────────────────┐
                  │      NGINX      │
                  │   TLS 1.2/1.3   │
                  │ Reverse Proxy   │
                  └────────┬────────┘
                           │
                           │ FastCGI
                           ▼
                  ┌─────────────────┐
                  │    WORDPRESS    │
                  │    PHP-FPM      │
                  └────────┬────────┘
                           │
                           │ MariaDB protocol
                           ▼
                  ┌─────────────────┐
                  │     MARIADB     │
                  │    Database     │
                  └─────────────────┘

              All containers communicate
              through a Docker network.

                    Persistent volumes
                         │       │
                         ▼       ▼
                    Database   WordPress
                      data       files
```

### NGINX

NGINX is the entry point of the infrastructure.

Its responsibilities are:

* Accept HTTPS connections.
* Use TLS 1.2 or TLS 1.3.
* Serve the domain `sabu-kha.42.fr`.
* Forward PHP requests to the WordPress container.
* Prevent direct external access to WordPress and MariaDB.

NGINX is the only container exposed to the external network.

### WordPress

The WordPress container contains:

* WordPress
* PHP
* PHP-FPM

WordPress handles the website and communicates with MariaDB to store and retrieve application data.

NGINX does not run inside this container.

### MariaDB

MariaDB is responsible for the WordPress database.

It runs in its own dedicated container and is not directly exposed to the host.

The database credentials are provided through Docker secrets and environment variables rather than being hard-coded inside the Dockerfile.

---

# Docker Design

## Why Docker?

Docker provides isolated environments for individual services.

Instead of installing NGINX, PHP-FPM, WordPress and MariaDB directly on the host system, each service is placed inside its own container.

This gives the infrastructure:

* Service isolation
* Reproducible environments
* Easier deployment
* Independent configuration
* Easier service management
* Controlled networking

The project requires each service to run in a dedicated container and requires the images to be built using our own Dockerfiles rather than pulling ready-made service images.

---

# Virtual Machine vs Docker

| Virtual Machine                        | Docker                                              |
| -------------------------------------- | --------------------------------------------------- |
| Virtualizes an entire operating system | Shares the host kernel                              |
| Usually heavier                        | Lightweight                                         |
| Each VM requires its own OS            | Containers contain the required user-space software |
| Slower to start                        | Fast to start                                       |
| Larger resource usage                  | Lower resource usage                                |
| Strong isolation at OS level           | Process/service isolation                           |

In this project, the Virtual Machine provides the required isolated environment for the activity, while Docker is used inside the VM to isolate the individual services.

---

# Docker Network vs Host Network

### Docker Network

Containers communicate through an isolated Docker network.

Advantages:

* Service isolation
* Container-to-container communication
* Internal DNS resolution
* No need to expose every service to the host

For example:

```text
nginx → wordpress → mariadb
```

The containers communicate internally using the Docker network.

### Host Network

With host networking, containers share the host's network namespace.

This provides less network isolation and is not suitable for the architecture required by this project.

The project explicitly requires a Docker network and prohibits using `network: host`.

---

# Docker Volumes vs Bind Mounts

## Docker Named Volumes

Named volumes are managed by Docker and are used for persistent data.

This project uses two named volumes:

1. WordPress database
2. WordPress website files

The project requires these to remain Docker named volumes rather than bind mounts. Their data is configured to reside under:

```text
/home/sabu-kha/data
```

on the host machine.

## Bind Mounts

A bind mount directly maps a host filesystem path into a container.

Example:

```text
./data:/var/lib/mysql
```

This is not used for the required persistent WordPress/database volumes because the subject specifically requires Docker named volumes.

---

# Secrets vs Environment Variables

## Environment Variables

Environment variables are useful for non-sensitive configuration.

For example:

```env
DOMAIN_NAME=sabu-kha.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=...
```

They allow configuration to be changed without modifying the Dockerfile.

## Docker Secrets

Sensitive values such as passwords should not be hard-coded into Dockerfiles or committed publicly.

This project uses Docker secrets for confidential credentials such as:

```text
db_root_password
db_password
```

The MariaDB initialization script reads these values from:

```text
/run/secrets/
```

The subject requires environment variables and a `.env` file, and strongly recommends Docker secrets for confidential information. Publicly stored credentials can result in project failure.

---

# Main Design Choices

## Separate container for each service

Each major service has its own container:

```text
NGINX
WordPress + PHP-FPM
MariaDB
```

This follows the principle of keeping services isolated and allows each component to be managed independently.

## NGINX as the only entry point

External traffic enters through NGINX using HTTPS.

```text
Client
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

MariaDB and WordPress are not directly exposed to the host.

The subject requires NGINX to be the only entry point through port `443` using TLS 1.2 or TLS 1.3.

## Persistent storage

Containers are ephemeral, so important data must be stored outside the container filesystem.

Two named volumes are used:

```text
wordpress database volume
wordpress files volume
```

This allows data to survive container recreation.

## Restart policy

The containers are configured to restart if they crash, as required by the subject.

---

# Project Structure

```text
inception/
│
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
│
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
│
└── srcs/
    ├── .env
    ├── docker-compose.yml
    │
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── mariadb-init.sh
        │
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── nginx-init.sh
        │
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

---

# Instructions

## Prerequisites

The project must be executed inside a Virtual Machine.

The environment requires:

* Linux
* Docker
* Docker Compose
* Make
* Git

The domain must resolve locally to the VM's IP address:

```text
sabu-kha.42.fr
```

For local testing, the domain can be configured through the host's `/etc/hosts` file.

Example:

```text
<VM_IP> sabu-kha.42.fr
```

## Build and Start

From the project root:

```bash
make
```

The Makefile builds and starts the complete infrastructure using Docker Compose.

Alternatively, Docker Compose can be executed from:

```bash
cd srcs
docker compose up --build
```

## Access the Website

Open:

```text
https://sabu-kha.42.fr
```

Because the project uses a locally generated TLS certificate, the browser may display a certificate warning during development.

## Stop the Infrastructure

```bash
make down
```

Or:

```bash
cd srcs
docker compose down
```

---

# Resources

Useful resources used to understand and implement the project include:

* Docker documentation
* Docker Compose documentation
* NGINX documentation
* MariaDB documentation
* WordPress documentation
* PHP-FPM documentation
* Linux documentation
* Docker networking documentation
* Docker volumes documentation
* Docker secrets documentation
* TLS/SSL documentation

The main purpose of using these resources was to understand the concepts before implementing them rather than relying on ready-made configurations.

---

# AI Usage

AI tools were used as a learning and debugging aid during the project.

Examples of AI-assisted tasks include:

* Understanding Docker and container concepts.
* Understanding Docker Compose configuration.
* Explaining NGINX, PHP-FPM and MariaDB roles.
* Troubleshooting configuration and runtime errors.
* Understanding shell scripts and Dockerfiles.
* Reviewing commands and their expected behavior.
* Helping structure project documentation.

AI-generated suggestions were reviewed, tested and adapted to the project. The implementation was not treated as a copy-paste solution.

The project guidelines emphasize that AI-generated content must be understood, reviewed and tested by the learner.

---

# Conclusion

Inception demonstrates how several independent services can be combined into a small infrastructure using Docker.

The final architecture separates:

```text
Reverse Proxy
     ↓
Application
     ↓
Database
```

while providing:

* HTTPS
* Service isolation
* Internal networking
* Persistent storage
* Secret management
* Container restart policies
* Reproducible builds

# Containers and Docker

---

> **Field** — DevOps / Containerization
> **Scope** — Docker concepts, commands, and debugging patterns used in this repository

---

## Overview

Docker packages applications into portable, isolated
units called containers. This section covers every
Docker concept encountered in the course, from basic
image building through production patterns like
health checks, multi-stage builds, and failure
diagnosis across Docker's four operational layers.

---

## Definitions

### `Docker Image`

**Definition.**
A packaged application snapshot that contains the
code, runtime, libraries, and configuration needed
to run an application. Images are built from
Dockerfiles and stored in registries.

**Context.**
Images are read-only templates. You never run an
image directly. Instead, you create a container
from an image. If the image is built wrong, every
container created from it inherits the problem.

**Example.**
```bash
docker build -t my-app:1.0 .
# builds an image tagged "my-app:1.0" from the
# Dockerfile in the current directory

docker images
# lists all local images
```

---

### `Container`

**Definition.**
A running instance of a Docker image. Containers
are isolated processes with their own filesystem,
network, and process space. They can be started,
stopped, and removed.

**Context.**
Containers are ephemeral by default. When a container
stops, any data written inside it is lost unless
you use volumes. This is a common source of confusion.

**Example.**
```bash
docker ps
# lists running containers

docker ps -a
# lists all containers including stopped ones

docker rm my-container
# removes a stopped container
```

---

### `Dockerfile`

**Definition.**
A text file containing instructions for building
a Docker image. Each instruction creates a layer
in the image. Common instructions include FROM,
COPY, RUN, and CMD.

**Context.**
The Dockerfile is where most build-time errors
originate. Reading it carefully reveals what the
image contains and how it starts.

**Example.**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

---

### `Entrypoint`

**Definition.**
The startup command or script that runs when a
container starts. It defines what the container
actually does. If the entrypoint fails, the
container exits immediately.

**Context.**
A missing or broken entrypoint is one of the most
common reasons for containers that start and
immediately stop (exit code 1 or 127).

**Example.**
```dockerfile
ENTRYPOINT ["python", "app.py"]
# container always runs app.py on startup

# Override at runtime:
docker run my-app /bin/bash
```

---

### `Health Check`

**Definition.**
A test that Docker or an orchestrator runs
periodically to confirm the application inside
a container is functioning correctly. It returns
healthy, unhealthy, or starting.

**Context.**
Without health checks, Docker only knows if a
container process is running, not if the application
is actually working. A process can be alive but
serving errors.

**Example.**
```dockerfile
HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -f http://localhost:8080/health || exit 1
```
```bash
docker inspect --format='{{.State.Health.Status}}' my-app
```

---

### `Volume`

**Definition.**
Persistent storage that exists outside the
container filesystem. Volumes survive container
restarts and removal. They are used for databases,
logs, and any data that must persist.

**Context.**
Volume permission errors are common. The user
inside the container must have permission to
read and write the mounted volume path.

**Example.**
```bash
docker run -v /host/data:/container/data my-app
# mounts host directory into the container

docker volume ls
# lists all Docker-managed volumes

docker volume rm my-volume
# removes a named volume
```

---

### `Bridge Network`

**Definition.**
Docker's default local network type. Containers
on the same bridge network can communicate with
each other by container name. Containers on
different networks are isolated.

**Context.**
Network creation failures (often related to
iptables or firewall rules) can prevent containers
from starting even when the image is correct.

**Example.**
```bash
docker network ls
# lists all Docker networks

docker network create my-net
# creates a custom bridge network

docker run --network my-net my-app
# attaches container to the custom network
```

---

### `Compose`

**Definition.**
A Docker tool for defining and running multi-
container applications using a YAML file. Compose
manages building images, creating networks and
volumes, and starting containers together.

**Context.**
Compose is the standard way to run local development
and lab environments. The `docker-compose.yml` file
is the single source of truth for the application
stack.

**Example.**
```bash
docker compose up -d --build
# build images and start all services in background

docker compose logs
# view logs from all services

docker compose down -v --remove-orphans
# stop and remove everything including volumes
```

---

### `Multi-Stage Build`

**Definition.**
A Dockerfile pattern that uses multiple FROM
instructions to create separate build and runtime
stages. The final image only contains what is
needed to run, not build tools or source code.

**Context.**
Multi-stage builds produce smaller, more secure
production images. They separate compilation
dependencies from runtime dependencies.

**Example.**
```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY . .
RUN npm ci && npm run build

# Runtime stage
FROM node:18-slim
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/server.js"]
```

---

### `Registry`

**Definition.**
A storage service for Docker images. Docker Hub
is the default public registry. Organizations
use private registries for internal images.

**Context.**
ImagePullBackOff errors in Kubernetes often mean
the image cannot be found in the registry, the
tag does not exist, or authentication failed.

**Example.**
```bash
docker push my-registry.io/my-app:1.0
# uploads image to a registry

docker pull my-registry.io/my-app:1.0
# downloads image from a registry
```

---

### `Container Logging`

**Definition.**
The output produced by a container's main process
(stdout and stderr). Docker captures this output
and makes it available through the logs command.

**Context.**
Container logs are the primary evidence source
for diagnosing application errors, crash loops,
and startup failures.

**Example.**
```bash
docker logs my-app
# show all logs

docker logs my-app --tail 50 -f
# follow last 50 lines in real time

docker compose logs app-service
# logs for one compose service
```

---

### `Non-Root User`

**Definition.**
Running a container process as a user other than
root (UID 0). This is a security best practice
that limits what a compromised container can do.

**Context.**
Production Dockerfiles should create and switch
to a non-root user. Volume mount permissions must
match this user.

**Example.**
```dockerfile
RUN adduser --disabled-password appuser
USER appuser
```

---

## Failure Layer Model

Docker problems fit into four layers. Identify
which layer failed before attempting fixes:

1. **Build layer** — image creation (Dockerfile errors)
2. **Host/runtime layer** — daemon, network, volumes
3. **Container startup layer** — entrypoint, env vars
4. **Application layer** — app logic, health endpoint

---

## Key Commands Summary

```bash
# Image operations
docker build -t <name>:<tag> .
docker images
docker rmi <image>

# Container operations
docker run -d --name <name> <image>
docker ps
docker ps -a
docker stop <container>
docker rm <container>
docker logs <container>
docker exec -it <container> /bin/bash
docker inspect <container>

# Compose operations
docker compose up -d --build
docker compose down -v --remove-orphans
docker compose logs
docker compose ps

# Network operations
docker network ls
docker network create <name>

# Volume operations
docker volume ls
docker volume rm <name>

# Cleanup
docker system prune -f
```

---

## See Also

- [Linux and System Administration](./01_linux_and_system_administration.md)
- [Kubernetes](./05_kubernetes.md)
- [Monitoring and Observability](./03_monitoring_and_observability.md)

---

> **Author** — Simon Parris | DevOps Reference Library

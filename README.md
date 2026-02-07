# Inception

*This project has been created as part of the 42 curriculum by ytabia.*

## Description

Inception is a system administration project that focuses on containerization using Docker. The goal is to set up a small infrastructure composed of different services following specific rules, all running in a virtualized environment using Docker Compose.

This project creates a complete web infrastructure with the following services:
- **NGINX** with TLSv1.2 or TLSv1.3 (web server)
- **WordPress** with php-fpm (content management system)
- **MariaDB** (database)

Each service runs in its own dedicated Docker container built from either Alpine Linux or Debian stable. The entire infrastructure is orchestrated using Docker Compose and can be started with a single `make` command.

The project emphasizes best practices in containerization, security (using secrets management), network isolation, and data persistence through volumes.

## Instructions

### Prerequisites

- Docker Engine (version 20.10 or higher)
- Docker Compose (version 1.29 or higher)
- GNU Make
- Sufficient disk space for Docker images and volumes

### Installation & Execution

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Configure the environment:
   - Edit the `.env` file in the `srcs/` directory with your credentials
   - Ensure the domain name is set to `ytabia.42.fr`
   - Add the domain to your `/etc/hosts` file:
     ```bash
     echo "127.0.0.1 ytabia.42.fr" | sudo tee -a /etc/hosts
     ```

3. Build and start the infrastructure:
```bash
make
```

4. Stop the infrastructure:
```bash
make down
```

5. Clean everything (containers, volumes, images):
```bash
make fclean
```

6. Rebuild from scratch:
```bash
make re
```

### Accessing the Services

- **WordPress site**: https://ytabia.42.fr
- **WordPress admin panel**: https://ytabia.42.fr/wp-admin

⚠️ **Note**: You will see a security warning in your browser because the SSL certificate is self-signed. This is expected behavior for this project.

## Project Architecture

### Docker vs Virtual Machines

**Virtual Machines** run a complete operating system with its own kernel on top of a hypervisor, consuming significant resources (RAM, CPU, disk space). Each VM includes a full OS installation.

**Docker containers** share the host's kernel and isolate only the application and its dependencies. They are:
- Lightweight (MBs vs GBs)
- Start in seconds vs minutes
- More efficient resource usage
- Better for microservices architecture

For this project, Docker is the ideal choice as we need isolated services that are lightweight, portable, and easy to orchestrate.

### Secrets vs Environment Variables

**Environment Variables** (`.env` file):
- Used for non-sensitive configuration (domain names, ports, usernames)
- Visible in container inspect and process lists
- Easy to manage and modify
- Suitable for development environments

**Docker Secrets**:
- Designed for sensitive data (passwords, API keys, certificates)
- Encrypted during transit and at rest in Swarm mode
- Mounted as files in `/run/secrets/` (tmpfs - RAM only)
- Not visible in environment variables or logs
- Production-grade security feature

In this project, we use `.env` for configuration variables and Docker secrets for passwords and sensitive credentials to follow security best practices.

### Docker Network vs Host Network

**Docker Network** (bridge mode):
- Isolated network for containers
- Internal DNS resolution (containers communicate by service name)
- Port mapping controls external access
- Better security through network isolation
- Allows multiple isolated networks

**Host Network**:
- Container uses host's network stack directly
- No network isolation
- No port mapping needed
- Less secure
- Performance advantage negligible for most applications

This project uses a custom Docker bridge network (`inception`) to ensure service isolation while allowing inter-container communication.

### Docker Volumes vs Bind Mounts

**Docker Volumes**:
- Managed by Docker in `/var/lib/docker/volumes/`
- Independent of host directory structure
- Better portability across different systems
- Can be managed with Docker CLI commands
- Better performance on non-Linux systems

**Bind Mounts**:
- Directly map host directories to container paths
- Absolute path dependency
- Full host filesystem access
- Useful for development and configuration files
- Performance native on Linux

This project uses **Docker volumes** for data persistence (WordPress files, database data) because they:
- Provide better abstraction and portability
- Are managed by Docker (easier backup and migration)
- Persist data independently of the host filesystem
- Follow Docker best practices for production environments

## Resources

### Technical Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/support/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Alpine Linux Documentation](https://wiki.alpinelinux.org/)

### Learning Resources
- [Docker Tutorial for Beginners](https://docker-curriculum.com/)
- [Understanding Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes Explained](https://docs.docker.com/storage/volumes/)
- [SSL/TLS Certificates with OpenSSL](https://www.openssl.org/docs/)

### AI Usage

AI assistance was utilized in the following areas of this project:

**Tasks:**
- **Debugging**: Troubleshooting container startup issues, network connectivity problems, and service configuration errors
- **Version Research**: Finding current stable versions of dependencies, PHP extensions, and packages compatible with Alpine/Debian
- **Concept Understanding**: Learning Docker networking, volumes, secrets management, and multi-stage builds
- **Configuration Guidance**: Understanding NGINX SSL configuration, PHP-FPM setup, and WordPress database connection

**Specific Parts:**
- **Dockerfile Optimization**: Understanding best practices for layer caching, multi-stage builds, and minimal image sizes
- **Security Practices**: Learning the difference between environment variables and Docker secrets, implementing proper secrets management
- **Configuration Files**: Understanding NGINX server blocks, PHP-FPM pool configuration, and MariaDB initialization scripts
- **Troubleshooting**: Resolving permission issues, container orchestration timing, and service dependencies

AI was used as a learning tool and debugging assistant, while all implementation, testing, and final code decisions were made independently to ensure full understanding of the infrastructure.

## Project Structure

```
inception/
├── Makefile   
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

## Additional Information

- All containers are built from scratch (no pre-built images from DockerHub, except base OS)
- Containers restart automatically on crash
- No infinite loops or hacky solutions (like `tail -f`, `sleep infinity`)
- Each service runs as PID 1 using proper init systems or direct process execution
- TLS 1.2/1.3 encryption for HTTPS traffic
- Data persists across container restarts through volumes

---

For detailed user instructions, see [USER_DOC.md](USER_DOC.md)  
For developer setup and technical details, see [DEV_DOC.md](DEV_DOC.md)
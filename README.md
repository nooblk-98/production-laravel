# Production Laravel Docker Stack

Docker-based Laravel runtime using `webdevops/php-nginx:8.2`, with separate compose files for app runtime, database, staging, and production deployments.

## What this repository contains

- `Dockerfile` for PHP 8.2 + Nginx app container
- `docker-compose.yml` for local app container
- `entrypoint.sh` to prepare Laravel storage/cache and warm common caches
- `database/docker-compose.yml` for MariaDB + phpMyAdmin
- `deployment/staging/docker-compose.yml` and `deployment/production/docker-compose.yml` examples

## Prerequisites

- Docker Desktop (or Docker Engine) with Compose v2
- Git
- A Laravel project (this repo already includes one in `application/`)

## Quick start (current sample app)

1. From repository root, create the root `.env` file if it does not exist.
	- This file is mounted into the container as `/var/www/html/.env`.
2. Build and run the app:

```bash
docker compose up --build -d
```

3. Open:
	- App: `http://localhost`

4. View logs:

```bash
docker compose logs -f app
```

5. Stop containers:

```bash
docker compose down
```

## Use this stack with your own Laravel application

This stack expects your Laravel source code inside the `application/` directory.

### Option A (recommended): replace `application/` with your app

1. Remove or rename the existing `application/` folder.
2. Copy your Laravel project into `application/`.
3. Ensure your app has `public/index.php`.
4. Put your runtime environment file at repository root as `.env` (not inside `application/`).
5. Rebuild and run:

```bash
docker compose up --build -d
```

### Option B: keep your app elsewhere

If you keep your code in another folder name, update the Dockerfile line:

```dockerfile
COPY application/ /var/www/html/
```

to match your folder, then rebuild:

```bash
docker compose up --build -d
```

## Database stack (MariaDB + phpMyAdmin)

1. Create external network once:

```bash
docker network create db-network
```

2. Start database services:

```bash
docker compose -f database/docker-compose.yml up -d
```

3. Open:
	- phpMyAdmin: `http://localhost:8090`

4. Default database env values are in `database/docker-compose.yml` and can be overridden with environment variables.

## Common commands

Run Laravel Artisan in the container:

```bash
docker compose exec app php artisan
```

Run migrations:

```bash
docker compose exec app php artisan migrate
```

Install/update PHP dependencies inside container:

```bash
docker compose exec app composer install
```

## Notes

- Container startup runs cache clear/cache commands and ensures storage permissions.
- PHP/Nginx limits (upload size, memory, etc.) are configured in `Dockerfile` via environment variables.
- This image uses PHP 8.2, so older Laravel versions may need compatibility updates.

## Deployment compose examples

- `deployment/staging/docker-compose.yml`
- `deployment/production/docker-compose.yml`

These are templates for running prebuilt images (`ghcr.io/...`) with mounted `storage` and `.env` from host paths.

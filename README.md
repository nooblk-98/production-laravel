# Production Laravel Docker Stack

Docker-based Laravel runtime using `webdevops/php-nginx:8.2`, with separate compose files for app runtime, database, staging, and production deployments.

## What this repository contains

- `Dockerfile` for PHP 8.2 + Nginx app container
- `docker-compose.yml` for local app container
- `entrypoint.sh` to prepare Laravel storage/cache and warm common caches
- `database/docker-compose.yml` for MariaDB + phpMyAdmin
- `deployment/staging/docker-compose.yml` and `deployment/production/docker-compose.yml` examples

## Which file is used for what

- `Dockerfile`: used to build image for local run and CI image build
- `docker-compose.yml`: local development run on your machine
- `deployment/production/docker-compose.yml`: live deployment using prebuilt image from GHCR
- `.github/workflows/deploy-to-prod.yml`: GitHub Actions workflow to prebuild image, push to GHCR, and (optionally) deploy

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

## Production deployment with prebuilt image

For live deployment, use `deployment/production/docker-compose.yml`.

- It does not build from source.
- It pulls a prebuilt image (`ghcr.io/...:production`).
- It mounts host `storage` and host `.env` into the container.

Typical production flow:

1. GitHub Action builds image from `Dockerfile`
2. Action pushes image to GHCR
3. Server deploy uses `deployment/production/docker-compose.yml` to pull and run that image

## GitHub Actions: build, push, deploy

Workflow file: `.github/workflows/deploy-to-prod.yml`

Current behavior in this repository:

- Trigger: push to `main` or manual run
- Build job: builds image from `Dockerfile`
- Push job step: pushes tags
	- `ghcr.io/<owner>/<project>:production`
	- `ghcr.io/<owner>/<project>:<commit-sha>`
- Deploy job block exists but is currently commented out
- Release job creates an automatic GitHub release tag

If you want fully automated live deployment, uncomment and configure the deploy job secrets in this workflow.

## Docker ENV variables in Dockerfile

These are application runtime defaults. You should tune them based on your project size, traffic, upload limits, and memory usage.

```dockerfile
ENV COMPOSER_ALLOW_SUPERUSER=1 \
		WEB_DOCUMENT_ROOT=/var/www/html/public \
		WEB_DOCUMENT_INDEX=index.php \
		SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=200M \
		PHP_UPLOAD_MAX_FILESIZE=200M \
		PHP_POST_MAX_SIZE=200M \
		PHP_OPCACHE_MEMORY_CONSUMPTION=2048 \
		PHP_MEMORY_LIMIT=2G
```

Variable meanings:

- `COMPOSER_ALLOW_SUPERUSER=1`
	- Allows Composer to run as root during image build.
	- Keep as `1` in container builds unless you switch to a non-root build user.

- `WEB_DOCUMENT_ROOT=/var/www/html/public`
	- Nginx document root.
	- For Laravel, keep this as `public`.

- `WEB_DOCUMENT_INDEX=index.php`
	- Default index file served by Nginx.
	- Usually keep `index.php` for Laravel.

- `SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=200M`
	- Max request body accepted by Nginx.
	- Increase for large uploads/imports; decrease for stricter limits.

- `PHP_UPLOAD_MAX_FILESIZE=200M`
	- Max size of a single uploaded file in PHP.

- `PHP_POST_MAX_SIZE=200M`
	- Max total POST payload size.
	- Set greater than or equal to upload max size.

- `PHP_OPCACHE_MEMORY_CONSUMPTION=2048`
	- OPcache memory (MB) for compiled PHP scripts.
	- Reduce for small apps or low-memory VPS; increase if OPcache gets full.

- `PHP_MEMORY_LIMIT=2G`
	- Max PHP memory per request.
	- Tune down for smaller servers (example: `256M` or `512M`) unless heavy jobs require more.

Suggested tuning starting points:

- Small CRUD app:
	- `SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=20M`
	- `PHP_UPLOAD_MAX_FILESIZE=20M`
	- `PHP_POST_MAX_SIZE=24M`
	- `PHP_OPCACHE_MEMORY_CONSUMPTION=256`
	- `PHP_MEMORY_LIMIT=256M`

- Medium app with exports/uploads:
	- `SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=64M`
	- `PHP_UPLOAD_MAX_FILESIZE=64M`
	- `PHP_POST_MAX_SIZE=72M`
	- `PHP_OPCACHE_MEMORY_CONSUMPTION=512`
	- `PHP_MEMORY_LIMIT=512M`

- High-load / heavy processing:
	- `SERVICE_NGINX_CLIENT_MAX_BODY_SIZE=200M`
	- `PHP_UPLOAD_MAX_FILESIZE=200M`
	- `PHP_POST_MAX_SIZE=200M`
	- `PHP_OPCACHE_MEMORY_CONSUMPTION=1024` to `2048`
	- `PHP_MEMORY_LIMIT=1G` to `2G`

After changing ENV values, rebuild image:

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

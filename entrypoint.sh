#!/bin/sh
set -eu

cd /var/www/html

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache || true
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rwx storage bootstrap/cache || true

if [ ! -f .env ] && [ -f .env.example ]; then
	cp .env.example .env
fi

if [ -f artisan ] && [ -f vendor/autoload.php ]; then
	if ! grep -q '^APP_KEY=base64:' .env 2>/dev/null; then
		php artisan key:generate || true
	fi

	php artisan optimize|| true
	php artisan storage:link || true
fi

exec "$@"
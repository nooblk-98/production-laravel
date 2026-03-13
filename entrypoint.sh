#!/bin/sh
set -eu

cd /var/www/html

APP_USER="1000"
APP_GROUP="1000"

mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache || true
TODAY_LOG="storage/logs/laravel-$(date +%F).log"
if [ ! -f "$TODAY_LOG" ]; then
	touch "$TODAY_LOG" || true
fi

chown -R "$APP_USER:$APP_GROUP" storage bootstrap/cache || true
chmod -R ug+rwx storage bootstrap/cache || true
chown "$APP_USER:$APP_GROUP" "$TODAY_LOG" || true
chmod 664 "$TODAY_LOG" || true


php artisan config:clear && php artisan config:cache || true
php artisan route:clear || true
php artisan view:clear && php artisan view:cache || true
php artisan storage:link --force || true

# if [ -f /var/www/html/pm2_cronjobs/start-pm2-jobs.sh ]; then
# 	sh /var/www/html/pm2_cronjobs/start-pm2-jobs.sh || true
# fi

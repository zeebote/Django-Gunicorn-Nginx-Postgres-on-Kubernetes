#!/bin/sh
set -e
if [ "$1" = "gunicorn" ]; then
  exec gunicorn --bind :8000 -w 3 --forwarded-allow-ips="*" apps.wsgi
fi
exec "$@"

#!/bin/bash
set -e

echo "Starting Django Channels Chat Application..."

# Wait for database to be ready
echo "Waiting for PostgreSQL..."
while ! nc -z ${POSTGRES_HOST:-db} ${POSTGRES_PORT:-5432}; do
  sleep 0.5
done
echo "PostgreSQL started"

# Wait for Redis to be ready
echo "Waiting for Redis..."
while ! nc -z ${REDIS_HOST:-redis} ${REDIS_PORT:-6379}; do
  sleep 0.5
done
echo "Redis started"

# Change to canal directory
cd /app/canal

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

echo "Starting Daphne ASGI server..."
# Start Daphne ASGI server
exec daphne -b 0.0.0.0 -p 8000 canal.asgi:application

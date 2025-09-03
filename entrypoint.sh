#!/bin/bash

# ZITADEL Railway Deployment Entrypoint Script
# Handles Railway's deployment patterns and prevents duplicate constraint errors

set -e

echo "Starting ZITADEL Railway deployment..."

# Wait for database to be ready
echo "Waiting for database connection..."
until pg_isready -h "$ZITADEL_DATABASE_POSTGRES_HOST" -p "$ZITADEL_DATABASE_POSTGRES_PORT" -U "$ZITADEL_DATABASE_POSTGRES_USER_USERNAME" -d "$ZITADEL_DATABASE_POSTGRES_DATABASE" 2>/dev/null; do
    echo "Database not ready, waiting 2 seconds..."
    sleep 2
done

echo "Database is ready!"

# Check if instance already exists by querying the database directly
INSTANCE_EXISTS=$(PGPASSWORD="$ZITADEL_DATABASE_POSTGRES_USER_PASSWORD" psql -h "$ZITADEL_DATABASE_POSTGRES_HOST" -p "$ZITADEL_DATABASE_POSTGRES_PORT" -U "$ZITADEL_DATABASE_POSTGRES_USER_USERNAME" -d "$ZITADEL_DATABASE_POSTGRES_DATABASE" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='instances';" 2>/dev/null || echo "0")

if [ "$INSTANCE_EXISTS" -gt 0 ]; then
    DOMAIN_EXISTS=$(PGPASSWORD="$ZITADEL_DATABASE_POSTGRES_USER_PASSWORD" psql -h "$ZITADEL_DATABASE_POSTGRES_HOST" -p "$ZITADEL_DATABASE_POSTGRES_PORT" -U "$ZITADEL_DATABASE_POSTGRES_USER_USERNAME" -d "$ZITADEL_DATABASE_POSTGRES_DATABASE" -t -c "SELECT COUNT(*) FROM instances WHERE domain='$ZITADEL_EXTERNALDOMAIN';" 2>/dev/null || echo "0")
    
    if [ "$DOMAIN_EXISTS" -gt 0 ]; then
        echo "Instance with domain $ZITADEL_EXTERNALDOMAIN already exists, starting normally..."
        exec zitadel start --masterkeyFromEnv --tlsMode external "$@"
    fi
fi

echo "No existing instance found, running initial setup..."
exec zitadel start-from-init --masterkeyFromEnv --tlsMode external --init-projections false "$@"
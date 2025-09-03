#!/bin/bash

# ZITADEL Railway Deployment Script
# Simplified approach to avoid complexity issues

set -e

echo "🚀 Starting ZITADEL Railway deployment..."
echo "📊 Environment check:"
echo "   - External Domain: ${ZITADEL_EXTERNALDOMAIN:-NOT_SET}"
echo "   - Database Host: ${ZITADEL_DATABASE_POSTGRES_HOST:-NOT_SET}"
echo "   - Database Name: ${ZITADEL_DATABASE_POSTGRES_DATABASE:-NOT_SET}"
echo "   - Master Key Set: ${ZITADEL_MASTERKEY:+YES}"

# Check if critical environment variables are set
if [ -z "$ZITADEL_EXTERNALDOMAIN" ]; then
    echo "❌ ERROR: ZITADEL_EXTERNALDOMAIN is not set!"
    exit 1
fi

if [ -z "$ZITADEL_DATABASE_POSTGRES_HOST" ]; then
    echo "❌ ERROR: ZITADEL_DATABASE_POSTGRES_HOST is not set!"
    exit 1
fi

if [ -z "$ZITADEL_MASTERKEY" ]; then
    echo "❌ ERROR: ZITADEL_MASTERKEY is not set!"
    exit 1
fi

echo "✅ Environment variables validated"

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
sleep 10

# Try start-from-init first (it will handle existing instances gracefully)
echo "🔧 Starting ZITADEL with initialization check..."
echo "🔧 Command: zitadel start-from-init --masterkeyFromEnv --tlsMode external"

exec zitadel start-from-init --masterkeyFromEnv --tlsMode external "$@"
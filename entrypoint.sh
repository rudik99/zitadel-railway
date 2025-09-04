#!/bin/bash

# ZITADEL Railway Deployment Script - Robust Solution
# Handles the restart loop and duplicate constraint issues

set -e

echo "🚀 Starting ZITADEL Railway deployment..."
echo "📊 Environment check:"
echo "   - External Domain: ${ZITADEL_EXTERNALDOMAIN:-NOT_SET}"
echo "   - Railway Domain: ${RAILWAY_PUBLIC_DOMAIN:-NOT_SET}"
echo "   - Database Host: ${ZITADEL_DATABASE_POSTGRES_HOST:-NOT_SET}"
echo "   - Database Name: ${ZITADEL_DATABASE_POSTGRES_DATABASE:-NOT_SET}"
echo "   - Master Key Set: ${ZITADEL_MASTERKEY:+YES}"

# Use Railway's provided domain if ZITADEL_EXTERNALDOMAIN is not set
if [ -z "$ZITADEL_EXTERNALDOMAIN" ]; then
    if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
        echo "⚡ Using Railway domain: $RAILWAY_PUBLIC_DOMAIN"
        export ZITADEL_EXTERNALDOMAIN="$RAILWAY_PUBLIC_DOMAIN"
    else
        echo "⚠️ WARNING: Neither ZITADEL_EXTERNALDOMAIN nor RAILWAY_PUBLIC_DOMAIN is set!"
        echo "⚠️ Using localhost as fallback (update this after first deployment)"
        export ZITADEL_EXTERNALDOMAIN="localhost"
    fi
fi

# Check critical environment variables
if [ -z "$ZITADEL_DATABASE_POSTGRES_HOST" ]; then
    echo "❌ ERROR: ZITADEL_DATABASE_POSTGRES_HOST is not set!"
    exit 1
fi

if [ -z "$ZITADEL_MASTERKEY" ]; then
    echo "❌ ERROR: ZITADEL_MASTERKEY is not set!"
    exit 1
fi

echo "✅ Environment variables validated"
echo "📍 Using domain: $ZITADEL_EXTERNALDOMAIN"

# Create PAT file path if needed
if [ -n "$ZITADEL_FIRSTINSTANCE_LOGINCLIENTPATPATH" ]; then
    echo "📝 Creating PAT file at: $ZITADEL_FIRSTINSTANCE_LOGINCLIENTPATPATH"
    mkdir -p $(dirname "$ZITADEL_FIRSTINSTANCE_LOGINCLIENTPATPATH")
    touch "$ZITADEL_FIRSTINSTANCE_LOGINCLIENTPATPATH"
fi

# Wait longer for database to be fully ready
echo "⏳ Waiting 15 seconds for database to be fully ready..."
sleep 15

# Try to start ZITADEL with the appropriate command
echo "🔧 Attempting to start ZITADEL..."

# First, try normal start (for existing instances)
echo "📍 Trying normal start first..."
if timeout 10 zitadel start --masterkeyFromEnv --tlsMode external 2>&1 | grep -q "failed to get instance"; then
    echo "❌ No existing instance found"
    echo "🔧 Running initial setup with start-from-init..."
    
    # Clear any partial data first by waiting longer
    echo "⏳ Waiting 10 seconds to ensure no concurrent operations..."
    sleep 10
    
    exec zitadel start-from-init --masterkeyFromEnv --tlsMode external
else
    echo "✅ Instance exists or initialization succeeded"
    exec zitadel start --masterkeyFromEnv --tlsMode external
fi
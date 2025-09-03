#!/bin/bash

# ZITADEL Railway Automated Deployment Script
# Automatically detects if initialization is needed and runs the appropriate command

set -e

echo "🚀 Starting ZITADEL Railway deployment..."
echo "📊 Environment check:"
echo "   - External Domain: ${ZITADEL_EXTERNALDOMAIN}"
echo "   - Database Host: ${ZITADEL_DATABASE_POSTGRES_HOST}"
echo "   - Database Name: ${ZITADEL_DATABASE_POSTGRES_DATABASE}"

# Function to check if ZITADEL database is initialized
check_database_initialized() {
    echo "🔍 Checking if ZITADEL database is initialized..."
    
    # Simple approach: try to run setup --steps and check output
    local setup_output
    setup_output=$(zitadel setup --steps 2>&1 || true)
    
    echo "📋 Setup check output: $setup_output"
    
    if echo "$setup_output" | grep -q "database is up to date\|no migration needed\|already applied"; then
        echo "✅ Database is already initialized"
        return 0
    else
        echo "❌ Database needs initialization"
        return 1
    fi
}

# Wait a moment for database to be ready
echo "⏳ Waiting for database connection..."
sleep 5

# Check if database is initialized
if check_database_initialized; then
    echo "🎯 Starting ZITADEL in normal mode..."
    echo "🔧 Command: zitadel start --masterkeyFromEnv --tlsMode external"
    exec zitadel start --masterkeyFromEnv --tlsMode external "$@"
else
    echo "🔧 Running ZITADEL initial setup..."
    echo "🔧 Command: zitadel start-from-init --masterkeyFromEnv --tlsMode external"
    exec zitadel start-from-init --masterkeyFromEnv --tlsMode external "$@"
fi
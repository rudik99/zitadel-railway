#!/bin/bash

# ZITADEL Railway Automated Deployment Script
# Automatically detects if initialization is needed and runs the appropriate command

set -e

echo "🚀 Starting ZITADEL Railway deployment..."

# Function to check if ZITADEL database is initialized
check_database_initialized() {
    echo "🔍 Checking if ZITADEL database is initialized..."
    
    # Try to run a quick database check using ZITADEL's built-in validation
    # We'll use the setup command with --steps to see what needs to be done
    if zitadel setup --steps 2>&1 | grep -q "database is up to date"; then
        echo "✅ Database is already initialized"
        return 0
    else
        echo "❌ Database needs initialization"
        return 1
    fi
}

# Check if database is initialized
if check_database_initialized; then
    echo "🎯 Starting ZITADEL in normal mode..."
    exec zitadel start --masterkeyFromEnv --tlsMode external "$@"
else
    echo "🔧 Running ZITADEL initial setup..."
    exec zitadel start-from-init --masterkeyFromEnv --tlsMode external "$@"
fi
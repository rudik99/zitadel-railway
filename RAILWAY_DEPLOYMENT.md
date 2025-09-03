# ZITADEL Railway Deployment Guide

## The Problem
You're encountering this error even with a clean database:

```
ERROR: duplicate key value violates unique constraint "unique_constraints_pkey" (SQLSTATE 23505)
```

This happens because:
1. **Railway restarts containers during deployment** causing multiple initialization attempts
2. **Database connection issues** causing ZITADEL to retry initialization
3. **Race conditions** during the setup process

## Solutions

### Option 1: Smart Entrypoint Script (Recommended)
The project now includes an intelligent entrypoint script that:
- Waits for database to be ready
- Checks if instance already exists before attempting creation
- Handles Railway's deployment patterns properly

**Files updated:**
- [`Dockerfile`](Dockerfile:1) - Uses the entrypoint script
- [`entrypoint.sh`](entrypoint.sh:1) - Smart initialization logic
- [`railway.json`](railway.json:1) - Railway-specific configuration

### Option 2: Manual Database Check
If the entrypoint script doesn't work, you can manually verify:

1. **Check your Railway database** for existing tables:
   ```sql
   SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
   ```

2. **If tables exist, check for your domain:**
   ```sql
   SELECT * FROM instances WHERE domain = 'your-railway-domain.up.railway.app';
   ```

3. **If domain exists, use `start` instead of `start-from-init`**

### Option 3: Railway Configuration Fixes
The [`railway.json`](railway.json:1) file includes:
- Longer healthcheck timeout (300s)
- Restart policy set to "never" to prevent multiple initialization attempts
- Proper healthcheck path for ZITADEL

### Option 4: Environment Variable Check
Ensure these Railway environment variables are correctly set:

**Critical Variables:**
- `ZITADEL_DATABASE_POSTGRES_HOST` - Railway PostgreSQL host
- `ZITADEL_DATABASE_POSTGRES_PORT` - Usually 5432
- `ZITADEL_DATABASE_POSTGRES_DATABASE` - Your database name
- `ZITADEL_DATABASE_POSTGRES_USER_USERNAME` - Database user
- `ZITADEL_DATABASE_POSTGRES_USER_PASSWORD` - Database password
- `ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME` - Admin user (often same as user)
- `ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD` - Admin password
- `ZITADEL_EXTERNALDOMAIN` - **MUST match your Railway domain exactly**
- `ZITADEL_EXTERNALSECURE=true`
- `ZITADEL_MASTERKEY` - Generate a secure 32-character key
- `ZITADEL_FIRSTINSTANCE_ORG_HUMAN_USERNAME` - Admin username
- `ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD` - Admin password
- `ZITADEL_FIRSTINSTANCE_ORG_HUMAN_EMAIL_ADDRESS` - Admin email

## Common Issues & Solutions

### Issue: Clean DB still shows duplicate constraint
**Cause:** Railway is restarting the container during initialization
**Solution:** The entrypoint script now handles this by checking database state first

### Issue: Database connection timeout
**Cause:** Database not ready when ZITADEL starts
**Solution:** Entrypoint script waits for database with `pg_isready`

### Issue: Domain mismatch
**Cause:** `ZITADEL_EXTERNALDOMAIN` doesn't match actual Railway domain
**Solution:** Ensure the domain matches exactly (e.g., `your-app-name.up.railway.app`)

## Deployment Steps
1. **Set all environment variables** in Railway
2. **Deploy with the updated files** (Dockerfile, entrypoint.sh, railway.json)
3. **Monitor logs** for "Database is ready!" and "No existing instance found"
4. **Wait for full initialization** (can take 2-5 minutes)

## Troubleshooting
- Check Railway logs for database connection messages
- Verify `ZITADEL_EXTERNALDOMAIN` matches your Railway URL exactly
- Ensure PostgreSQL service is running and accessible
- If still failing, try deleting and recreating the PostgreSQL service
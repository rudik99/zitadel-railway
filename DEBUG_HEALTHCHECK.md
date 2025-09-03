# ZITADEL Railway Healthcheck Debugging

## Current Issue
The healthcheck keeps failing because ZITADEL isn't starting properly. The container runs but the service is "unavailable".

## Changes Made to Debug

### 1. Disabled Healthcheck Temporarily
- **Removed healthcheck** from [`railway.json`](railway.json:1) to see actual startup logs
- **No timeout pressure** - container will stay running to show real errors

### 2. Simplified Entrypoint Script
- **Environment validation** - Checks if critical variables are set
- **Clearer logging** - Shows exactly what's happening
- **Simplified approach** - Uses `start-from-init` directly (it handles existing instances)

## What to Look For in Logs

### Expected Startup Sequence:
```
🚀 Starting ZITADEL Railway deployment...
📊 Environment check:
   - External Domain: your-app.up.railway.app
   - Database Host: your-db-host
   - Database Name: railway
   - Master Key Set: YES
✅ Environment variables validated
⏳ Waiting for database connection...
🔧 Starting ZITADEL with initialization check...
🔧 Command: zitadel start-from-init --masterkeyFromEnv --tlsMode external
```

### Then ZITADEL Should Show:
```
time="..." level=info msg="starting zitadel"
time="..." level=info msg="connecting to database"
time="..." level=info msg="database connection established"
time="..." level=info msg="running migrations"
time="..." level=info msg="server listening on port 8080"
```

## Common Issues to Check

### 1. Environment Variable Problems
If you see:
```
❌ ERROR: ZITADEL_EXTERNALDOMAIN is not set!
❌ ERROR: ZITADEL_DATABASE_POSTGRES_HOST is not set!
❌ ERROR: ZITADEL_MASTERKEY is not set!
```

**Fix:** Check your Railway environment variables are set correctly.

### 2. Database Connection Issues
If you see:
```
failed to connect to database
connection refused
timeout
```

**Fix:** 
- Verify PostgreSQL service is running
- Check database credentials
- Ensure database host/port are correct

### 3. ZITADEL Configuration Errors
If you see:
```
invalid configuration
missing required field
```

**Fix:** Check environment variables match ZITADEL requirements.

### 4. Port/Network Issues
If ZITADEL starts but healthcheck still fails:
```
server listening on port 8080
```
But healthcheck fails - this means ZITADEL is running but not responding to HTTP requests.

## Next Steps

### 1. Deploy and Check Logs
Deploy with these changes and look at the **Deploy Logs** tab in Railway to see:
- Environment validation output
- ZITADEL startup messages
- Any error messages

### 2. If Environment Variables Are Missing
Set these in Railway:
- `ZITADEL_EXTERNALDOMAIN` - Your Railway domain
- `ZITADEL_DATABASE_POSTGRES_HOST` - From Railway PostgreSQL service
- `ZITADEL_DATABASE_POSTGRES_PORT` - Usually 5432
- `ZITADEL_DATABASE_POSTGRES_DATABASE` - Database name
- `ZITADEL_DATABASE_POSTGRES_USER_USERNAME` - Database user
- `ZITADEL_DATABASE_POSTGRES_USER_PASSWORD` - Database password
- `ZITADEL_DATABASE_POSTGRES_ADMIN_USERNAME` - Admin user
- `ZITADEL_DATABASE_POSTGRES_ADMIN_PASSWORD` - Admin password
- `ZITADEL_MASTERKEY` - 32-character secure key
- `ZITADEL_EXTERNALSECURE=true`

### 3. If ZITADEL Starts Successfully
Once you see "server listening on port 8080", we can re-enable the healthcheck:

```json
{
  "deploy": {
    "healthcheckPath": "/debug/ready",
    "healthcheckTimeout": 600
  }
}
```

### 4. Alternative Healthcheck Endpoints
If `/debug/ready` doesn't work, try:
- `/debug/healthz`
- `/healthz` 
- `/` (root path)

## Expected Timeline
- **Environment validation**: Immediate
- **Database connection**: 10-30 seconds
- **ZITADEL startup**: 2-5 minutes
- **Ready to serve**: 3-8 minutes total

The key is seeing the actual ZITADEL startup logs to understand what's failing.
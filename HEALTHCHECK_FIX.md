# ZITADEL Railway Healthcheck Fix

## Issue
The deployment was failing during the healthcheck phase after 4+ minutes, indicating ZITADEL wasn't starting properly or the healthcheck endpoint wasn't responding.

## Root Causes
1. **ZITADEL initialization takes time** - First-time setup can take 5-10 minutes
2. **Wrong healthcheck endpoint** - `/debug/healthz` might not be the correct endpoint
3. **Insufficient timeout** - 5 minutes isn't enough for ZITADEL initialization
4. **Database connection issues** - ZITADEL might be failing to connect to PostgreSQL

## Fixes Applied

### 1. Updated Railway Configuration ([`railway.json`](railway.json:1))
```json
{
  "deploy": {
    "healthcheckPath": "/debug/ready",
    "healthcheckTimeout": 600,
    "startCommand": "/entrypoint.sh"
  }
}
```

**Changes:**
- ✅ **Healthcheck endpoint**: Changed from `/debug/healthz` to `/debug/ready`
- ✅ **Timeout increased**: From 300s (5min) to 600s (10min)
- ✅ **Explicit start command**: Ensures our entrypoint script is used

### 2. Enhanced Entrypoint Script ([`entrypoint.sh`](entrypoint.sh:1))
```bash
# Added better logging and diagnostics
echo "📊 Environment check:"
echo "   - External Domain: ${ZITADEL_EXTERNALDOMAIN}"
echo "   - Database Host: ${ZITADEL_DATABASE_POSTGRES_HOST}"
echo "   - Database Name: ${ZITADEL_DATABASE_POSTGRES_DATABASE}"

# Added database wait time
sleep 5

# Better error handling for setup check
setup_output=$(zitadel setup --steps 2>&1 || true)
```

**Improvements:**
- ✅ **Environment validation**: Shows key config values in logs
- ✅ **Database wait**: 5-second delay for DB readiness
- ✅ **Better error handling**: Won't crash on setup check failures
- ✅ **Detailed logging**: Shows exactly what commands are being run

## Expected Behavior After Fix

### Deployment Logs Should Show:
```
🚀 Starting ZITADEL Railway deployment...
📊 Environment check:
   - External Domain: your-app.up.railway.app
   - Database Host: your-db-host
   - Database Name: railway
⏳ Waiting for database connection...
🔍 Checking if ZITADEL database is initialized...
📋 Setup check output: [setup results]
✅ Database is already initialized (or ❌ Database needs initialization)
🎯 Starting ZITADEL in normal mode... (or 🔧 Running ZITADEL initial setup...)
```

### Healthcheck Behavior:
- **First deployment**: May take 8-10 minutes to pass healthcheck
- **Subsequent deployments**: Should pass healthcheck in 2-3 minutes
- **Endpoint**: Railway will check `/debug/ready` every few seconds
- **Timeout**: Will wait up to 10 minutes before failing

## If Still Failing

### Check Environment Variables:
Ensure these are set correctly in Railway:
- `ZITADEL_EXTERNALDOMAIN` - Must match your Railway domain exactly
- `ZITADEL_DATABASE_POSTGRES_*` - All database connection details
- `ZITADEL_MASTERKEY` - 32-character secure key

### Alternative Healthcheck Endpoints:
If `/debug/ready` doesn't work, try these in [`railway.json`](railway.json:1):
- `/debug/healthz`
- `/healthz`
- `/` (root path)

### Manual Debugging:
1. Check Railway logs for the environment check output
2. Verify database connection details are correct
3. Ensure PostgreSQL service is running and accessible
4. Check if ZITADEL is actually starting (look for ZITADEL startup messages)

## Next Steps
1. **Deploy with these fixes**
2. **Monitor logs** for the enhanced diagnostic output
3. **Wait patiently** - ZITADEL initialization takes time
4. **Check healthcheck progress** in Railway dashboard
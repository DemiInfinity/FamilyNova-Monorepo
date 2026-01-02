# Vercel Monorepo Configuration

This document explains how Vercel is configured to only build projects that have changed.

## How It Works

Each project has an `ignoreCommand` in its `vercel.json` that checks if files in that project's directory have changed:

- **Backend** (`backend/vercel.json`): Checks if files in `backend/` have changed
- **Web App** (`apps/web/vercel.json`): Checks if files in `apps/web/` have changed

## Ignore Command Logic

Vercel's `ignoreCommand` works as follows:
- **Exit code 0** = Skip the build (ignore)
- **Exit code non-zero** = Run the build

The command used:
```bash
if [ -z "$VERCEL_GIT_COMMIT_SHA" ] || [ -z "$VERCEL_GIT_PREVIOUS_SHA" ]; then exit 1; fi
git diff --quiet $VERCEL_GIT_PREVIOUS_SHA $VERCEL_GIT_COMMIT_SHA -- . && exit 0 || exit 1
```

This command:
1. Checks if Vercel's git environment variables are available (if not, builds to be safe)
2. Uses `git diff --quiet` to check if files in the current directory (`.`) have changed
3. If no changes: exits 0 (skip build) ✓
4. If changes exist: exits 1 (run build) ✓

**Important**: The `.` in the git diff command refers to the Vercel project's root directory:
- For backend project (root: `backend/`), it checks files in `backend/`
- For web app project (root: `apps/web/`), it checks files in `apps/web/`

## Project Setup in Vercel

### Backend Project
1. **Root Directory**: `backend`
2. **Build Command**: (empty or `npm install`)
3. **Output Directory**: (empty)
4. **Framework Preset**: Other

### Web App Project
1. **Root Directory**: `apps/web`
2. **Build Command**: `npm run build`
3. **Output Directory**: `.next`
4. **Framework Preset**: Next.js

## Testing

To test if the ignore command works:

1. Make a change in `backend/src/routes/` and push
   - Backend should build
   - Web app should be skipped

2. Make a change in `apps/web/app/` and push
   - Web app should build
   - Backend should be skipped

3. Make a change in `Docs/` or `apps/android-kids/` and push
   - Both projects should be skipped

## Notes

- The `ignoreCommand` checks changes between `HEAD^` (previous commit) and `HEAD` (current commit)
- On the first deployment, there may be no `HEAD^`, so Vercel will build everything
- Changes to shared files (like root `.gitignore`) will trigger builds for all projects that reference them


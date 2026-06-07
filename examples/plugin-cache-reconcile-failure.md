# Example: Bundled Plugin Cache Reconcile Failure

## User Symptom

After Codex Desktop updates or restarts, one or more bundled plugins appear enabled but fail when used. Chrome, Computer Use, or both may be affected.

## Evidence To Look For

Recent logs may include:

```text
bundled_plugins_marketplace_install_failed
bundled_plugins_reconcile_failed
plugin_cache_windows_file_lock
failed to back up plugin cache entry
Access is denied
os error 5
```

File checks may show:

- A missing version directory under `%USERPROFILE%\.codex\plugins\cache\openai-bundled`.
- A bundled marketplace mirror that exists but is incomplete.
- Helper paths or native host paths pointing to files that no longer exist.

## Plain-Language Cause

Codex Desktop keeps bundled plugin files in a user cache. During update or startup, Codex may reconcile that cache with the bundled marketplace. If Windows refuses to move, delete, or replace a file because another process still has it open, the cache can end up incomplete.

## Safe Agent Response

The agent should:

1. Confirm the affected surface.
2. Check logs and path existence before proposing repair.
3. Try a new thread or restart if local files look correct but the current thread lacks capability.
4. If cache damage is likely, explain the evidence and ask for approval before file changes.
5. Rebuild only default bundled cache paths from the installed official Codex source.
6. Validate the real plugin surface after repair.

## What Not To Do

- Do not delete `%USERPROFILE%\.codex`.
- Do not download random replacement plugin files.
- Do not hardcode another user's AppX or bundled plugin version path.
- Do not report success after only checking that files exist.

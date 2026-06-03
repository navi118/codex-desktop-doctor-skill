# Example: Chrome File Lock After Codex Update

## User Symptom

After updating Codex Desktop on Windows, `@Chrome` no longer works. Chrome itself opens normally, but Codex cannot control it. Computer Use may also disappear or become unavailable.

## Evidence To Look For

Recent Codex logs may contain:

```text
bundled_plugins_marketplace_install_failed
bundled_plugins_reconcile_failed
plugin_cache_windows_file_lock
failed to back up plugin cache entry
Access is denied
os error 5
```

Chrome checks may show:

- Chrome is installed.
- Chrome is running.
- Codex Chrome Extension is installed and enabled.
- Native host manifest exists.
- Current thread still cannot access the real Chrome extension backend, or cache reconciliation failed before the backend loaded.

## Plain-Language Cause

Windows can lock executable files that are currently running. If Chrome or the Codex Chrome native host is active while Codex updates bundled plugin files, Codex may fail to move or replace a cache entry. That failure can leave plugin cache state incomplete.

## Safe Agent Response

The agent should:

1. Explain that normal Chrome browsing does not prove the Codex Chrome plugin works.
2. Check extension and native host state.
3. Check whether the current thread sees the Chrome backend. The backend may be named `extension`.
4. Inspect bundled plugin cache and recent logs.
5. If cache repair is needed, ask the user to close Codex and Chrome before file changes.
6. Rebuild only from official installed Codex source into official default user cache paths.
7. Validate by using the actual Chrome extension backend.

## What Not To Do

- Do not open a webpage with a separate browser automation method and call the plugin fixed.
- Do not delete the whole `.codex` directory.
- Do not hardcode another user's plugin version.

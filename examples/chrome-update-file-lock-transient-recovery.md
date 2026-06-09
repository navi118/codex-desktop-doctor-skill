# Example: Chrome File Lock With Later Recovery

## User Symptom

Codex Desktop updates or starts while Chrome is still open. During bundled plugin reconciliation, the Chrome plugin cache update can fail with a Windows file lock or access denied error.

The user may see Chrome or Computer Use fail temporarily, or may only notice the issue later in logs.

## Sanitized Evidence

Short sanitized timeline:

```text
bundled_plugin_reinstall_uninstall_requested pluginName=chrome reason=forced
bundled_plugins_marketplace_install_failed pluginName=chrome errorCategory=plugin_cache_windows_file_lock
failed to remove existing plugin cache entry: access denied / os error 5
bundled_plugins_reconcile_failed reason=startup
bundled_plugins_reconcile_completed reason=focus
```

## Plain-Language Cause

Chrome or the Codex Chrome extension host may still be running while Codex tries to remove or replace the bundled Chrome plugin cache. Windows can refuse that file operation because the file is locked.

If a later reconcile succeeds, the failure may be transient rather than persistent cache damage. The important distinction is whether the real plugin surfaces work after the later successful reconcile.

## Expected Health Report Signal

The read-only health report should classify this as:

```text
transient-failure-followed-by-success
```

with:

```text
fileLockEvidence = true
affectedPlugins = chrome
```

## Safe Agent Response

The agent should:

1. Explain that Chrome being open during update can lock files Codex is trying to replace.
2. Check whether a later `bundled_plugins_reconcile_completed` event exists after the failure.
3. If a later success exists, classify it as likely recovered but still validate the real surfaces.
4. Validate Chrome through the actual Codex Chrome extension backend.
5. Validate Computer Use through the official Computer Use helper.
6. Avoid cache repair unless functional validation or missing files show persistent damage.

## What Not To Do

- Do not claim persistent cache damage from an old failure line if a later successful reconcile exists.
- Do not claim recovery only because files exist.
- Do not delete `.codex`.
- Do not repair while Chrome and Codex are still open unless the user explicitly accepts the risk and the repair is designed for that state.

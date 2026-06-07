# Decision Tree

Use this decision tree when a Windows user reports that Codex Desktop Chrome or Computer Use stopped working.

## 1. Identify The Affected Surface

Ask which surface is actually broken:

- Chrome plugin: Codex cannot control Chrome through the Codex Chrome Extension.
- Computer Use: Codex cannot control Windows apps.
- Both: Chrome and Computer Use failed around the same update or restart.
- Capability loading: settings show a plugin enabled, but the current thread does not expose the related tool/backend.

If the user reports GitHub, Gmail, Drive, Photoshop, Cloudflare, automations, or model routing, stop and explain that this project does not cover that scope yet.

## 2. Check Whether It Is A Real Plugin Failure

Do not accept substitute evidence.

Chrome is not proven healthy just because:

- Chrome.exe runs.
- A webpage opens.
- Another browser automation path works.

Computer Use is not proven healthy just because:

- PowerShell can launch an app.
- A script can press keys.
- The app itself opens normally.

The real checks are:

- Chrome: the Codex Chrome Extension backend can be reached and used.
- Computer Use: the official Computer Use client can list apps or inspect windows.

## 3. If Chrome Is Broken

Check in this order:

1. Is Chrome installed?
2. Is Chrome running when extension communication is expected?
3. Is the Codex Chrome Extension installed in the selected profile?
4. Is the extension enabled?
5. Is the native messaging host manifest present?
6. Does the registry point to the same manifest?
7. Does the current Codex thread expose the Chrome backend?

Important detail:

- The backend may appear as `extension`, not literally `chrome`.
- If the backend exists and works, Chrome is healthy even if a literal `chrome` lookup fails.

## 4. If Computer Use Is Broken

Check in this order:

1. Is `computer-use@openai-bundled` enabled?
2. Does the Computer Use cache version directory exist?
3. Does the configured helper executable path exist?
4. Do logs mention `missing-helper-path`?
5. Do logs mention native pipe startup failure?
6. Can the official Computer Use client list apps?

If the official client can list apps, Computer Use is reachable.

## 5. If Both Failed After An Update

Look for bundled plugin reconcile evidence:

```text
bundled_plugins_marketplace_install_failed
bundled_plugins_reconcile_failed
plugin_cache_windows_file_lock
failed to back up plugin cache entry
os error 5
Access is denied
```

Likely cause:

1. Chrome or a native host kept a file locked.
2. Codex tried to reconcile bundled plugin cache during update/startup.
3. Windows denied the file operation.
4. Plugin cache or marketplace state became partial.
5. Computer Use later failed because helper paths were missing or not wired.

## 6. Choose The Next Action

Use this mapping:

| Evidence | Action |
| --- | --- |
| Extension missing or disabled | Ask the user to install or enable the Codex Chrome Extension. |
| Native host manifest missing or invalid | Ask the user to reinstall the Chrome plugin from Codex plugin UI. |
| Backend not exposed in current thread but local checks pass | Try a new Codex thread or restart Codex before editing files. |
| `missing-helper-path` with missing Computer Use cache files | Consider default-path bundled cache repair with backup and approval. |
| `plugin_cache_windows_file_lock` after update | Close Chrome and Codex, then repair or let Codex rebuild default cache. |
| Enabled plugin points to missing or old versioned path | Classify as version drift; rebuild only from official installed Codex source after approval. |
| Permission or app approval denied | Ask the user to approve app control; do not edit cache. |

## 7. Validate Before Saying Fixed

Finish only after the real surface works:

- Chrome: the Codex Chrome Extension backend can list or use tabs.
- Computer Use: the official Computer Use client can list apps.

If validation cannot run, say the result is inconclusive.

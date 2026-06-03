---
name: codex-desktop-doctor
description: Diagnose Codex Desktop Chrome and Computer Use failures on Windows, especially after Codex updates, plugin cache reconciliation failures, Chrome extension/native-host issues, missing Computer Use helper paths, plugin_cache_windows_file_lock, missing-helper-path, native pipe startup failures, or cases where Chrome/Computer Use appears enabled but the current thread cannot actually use it.
---

# Codex Desktop Doctor

Use this skill to diagnose and safely recover Codex Desktop **Chrome** and **Computer Use** plugin failures on Windows. Keep the scope narrow: do not diagnose GitHub, Gmail, Drive, Photoshop, Cloudflare, or unrelated connector issues unless the user explicitly expands the scope.

This is an agent workflow, not a universal repair script. Inspect the user's actual machine, explain the evidence in plain language, and only propose repairs that preserve Codex default paths.

## Core Rule

Never present a workaround as a repair.

Examples:
- If Chrome opens through another browser automation path, that does not prove the Codex Chrome plugin works.
- If raw PowerShell can launch an app, that does not prove Computer Use works.
- If plugin cache files exist, that does not prove the current thread has the Chrome or Computer Use backend loaded.

Verify the real surface the user asked about.

## Workflow

1. Confirm scope.
   - Chrome plugin unavailable, broken after update, extension cannot connect, or Chrome backend missing.
   - Computer Use unavailable, Windows apps cannot be controlled, native pipe failed, or helper path missing.
   - If the issue is another connector, say this skill is not the right scope.

2. Gather evidence before changing anything.
   - Read relevant Codex config, plugin cache paths, marketplace paths, and recent logs.
   - Check whether the current thread exposes the required skill/tool path.
   - For Chrome, inspect Chrome running state, extension state, native host manifest, and actual browser backend identity.
   - For Computer Use, inspect the helper path, native pipe logs, and whether the official Computer Use client can list apps.

3. Classify the failure.
   - File lock during update or plugin reconciliation.
   - Partial bundled plugin cache or marketplace mirror.
   - Chrome extension/native host mismatch.
   - Computer Use helper path missing.
   - Current-thread backend/tool not exposed even though local files are present.
   - User permission or app approval issue.

4. Explain why it happened.
   - On Windows, running executables and native hosts can keep file handles open.
   - Codex updates may reconcile bundled plugins by backing up, removing, or replacing mutable cache directories.
   - If Chrome or an extension host keeps a file locked during that operation, reconcile can fail with access denied.
   - A partial bundled plugin state can break Computer Use too, because Computer Use depends on helper files and notification/native pipe setup in the same bundled plugin cache family.

5. Repair only when evidence is strong.
   - Prefer closing Codex and Chrome cleanly, then letting Codex rebuild official plugin state.
   - If manual cache rebuild is needed, rebuild only from the installed official Codex bundled source to Codex default cache locations.
   - Back up before replacing anything.
   - Do not modify arbitrary paths, do not hardcode another user's version path, and do not delete the entire `.codex` directory.

6. Validate after repair.
   - Chrome: confirm the Codex Chrome Extension is installed and enabled, native host manifest is correct, and the actual Chrome extension backend can list or use tabs.
   - Computer Use: confirm the official Computer Use client can list Windows apps.
   - Logs should no longer show missing helper path or native pipe startup failure.

## Reference Files

Read these only when needed:

- `references/chrome-and-computer-use.md`: practical diagnosis workflow, safe checks, and validation rules.
- `references/evidence-patterns.md`: log messages and what they usually mean.
- `references/safe-repair-boundaries.md`: allowed repairs, forbidden repairs, and user approval boundaries.

## Reporting Style

Give the user a short diagnosis in this shape:

```text
Status:
- Chrome: working / broken / inconclusive
- Computer Use: working / broken / inconclusive

Likely cause:
- Plain-language root cause with evidence.

What I checked:
- Key paths, logs, and functional checks.

Next action:
- No action needed, reconnect/restart, safe rebuild, or cannot repair locally.
```

If evidence is incomplete, say so. Do not claim a repair is complete until functional checks pass.

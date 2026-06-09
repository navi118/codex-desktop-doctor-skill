# Evidence Patterns

Use these patterns as clues, not as automatic proof. Always combine log evidence with path checks and functional validation.

## Plugin Cache Or Marketplace Reconcile Failure

Signals:

```text
bundled_plugins_marketplace_install_failed
bundled_plugins_reconcile_failed
plugin_cache_windows_file_lock
os error 5
Access is denied
failed to back up plugin cache entry
failed to install plugin
```

Likely meaning:
- Codex tried to update or reconcile bundled plugins.
- Windows refused a file operation, often because Chrome or a native host kept a file handle open.
- The bundled plugin cache or marketplace mirror may be partial.

Do not assume:
- Do not assume the only broken plugin is the one named in the first log line.
- A Chrome cache failure can leave Computer Use broken too.

Important nuance:
- If a later `bundled_plugins_reconcile_completed` appears after the failure, classify the event as a transient failure followed by apparent recovery.
- If no later successful reconcile appears in the scanned logs, classify it as possible persistent cache damage.
- In both cases, functional validation is still required before saying Chrome or Computer Use is healthy.

## Computer Use Helper Missing

Signals:

```text
missing-helper-path
Windows Computer Use helper paths are unavailable
computer-use native pipe startup failed
computer-use notify config ensure finished
status=skipped
```

Likely meaning:
- Codex cannot resolve the Computer Use helper executable.
- The plugin cache may be missing, partial, or config may point to a path that no longer exists.

Next checks:
- Confirm the configured helper path exists.
- Confirm the Computer Use plugin cache has the expected version directory.
- Confirm the official Computer Use client can or cannot list apps.

## Chrome Extension Or Native Host Mismatch

Signals:

```text
Cannot communicate with the Codex Chrome Extension
native host manifest missing
native host manifest invalid
extension not installed
extension disabled
Browser is not available
```

Likely meaning:
- Chrome, the extension, or the native host handshake is not working.
- If the backend list shows Chrome as `extension`, use that backend identity rather than assuming the literal name `chrome`.

Next checks:
- Chrome installed and running.
- Extension installed and enabled in the selected profile.
- Native host manifest exists and registry points to it.
- Actual Chrome extension backend can list tabs.

## Thread Capability Loading Problem

Signals:

```text
tool not found
backend not available in this thread
config enabled but no callable tool/backend appears
```

Likely meaning:
- Local plugin files may be fine, but the current Codex thread did not expose the capability.
- This can happen after connector or plugin changes until the thread or app refreshes.

Safe next action:
- Try tool discovery again.
- Try a new Codex thread.
- Restart Codex if the new thread still cannot load the capability.
- Do not rebuild plugin cache unless file/log evidence also supports cache corruption.

## Version Drift Or Partial Bundled State

Signals:

```text
plugin cache entry not found
marketplace entry missing
bundled marketplace path missing
helper path points to older version
enabled plugin exists but callable backend does not appear
```

Likely meaning:
- Codex Desktop, the bundled marketplace mirror, and the user plugin cache may not agree on the same plugin version.
- A previous update or cleanup may have left stale paths in config or state.

Next checks:
- Compare the installed Codex app version with the versioned bundled plugin cache directories.
- Confirm the enabled plugin points to an existing default cache path.
- Confirm the current thread exposes the capability after a fresh thread or app restart.

Do not assume:
- Do not hardcode a version path from another machine.
- Do not call version drift fixed until the real Chrome or Computer Use surface works.

## User Approval Or App Permission Issue

Signals:

```text
Computer Use stopped
Computer Use unavailable for current turn
user denied app control
approval required
```

Likely meaning:
- The system may be working, but the user has not allowed the app/control path.

Safe next action:
- Explain the permission issue.
- Ask the user to allow the app or retry the action.
- Do not edit plugin cache.

# Read-Only Health Report

This project includes an optional read-only PowerShell report helper:

```powershell
.\scripts\codex-desktop-health-report.ps1
```

The helper prints a JSON report to stdout. It does not repair files, delete caches, reinstall plugins, edit configuration, launch Chrome, or control Windows apps.

To save a report for an issue:

```powershell
.\scripts\codex-desktop-health-report.ps1 > codex-desktop-health-report.json
```

## What It Collects

- Windows version basics.
- Installed Codex AppX package information when available.
- Whether the default Codex plugin cache paths exist.
- Bundled plugin names and version directories under `openai-bundled`.
- Whether expected Chrome and Computer Use helper files exist in versioned plugin folders.
- Process counts for Codex, Chrome, Chrome extension host, and Computer Use helper.
- Counts of common error strings in recent Codex Desktop app logs.
- A bounded bundled plugin reconcile timeline.
- Whether a recent reconcile failure was followed by a later successful reconcile.

## What It Avoids

- It does not include full log lines.
- It does not scan Codex thread session files.
- It replaces the user profile path with `%USERPROFILE%`.
- It does not collect tokens, API keys, emails, prompts, browser cookies, local storage, passwords, or Chrome profile contents.
- It does not prove a repair. It only prepares evidence for diagnosis.

## Useful Error Patterns

The report counts patterns such as:

```text
bundled_plugins_marketplace_install_failed
bundled_plugins_reconcile_failed
plugin_cache_windows_file_lock
failed to remove existing plugin cache entry
os error 5
missing-helper-path
Windows Computer Use helper paths are unavailable
computer-use native pipe startup failed
Cannot communicate with the Codex Chrome Extension
```

## How To Interpret It

### Reconcile Assessment

The report includes `logs.reconcileAssessment.status`.

Useful statuses:

```text
no-recent-reconcile-failure
transient-failure-followed-by-success
failure-without-later-success
```

`transient-failure-followed-by-success` means the report found a bundled plugin reconcile failure and then found a later `bundled_plugins_reconcile_completed` event. This suggests Codex may have recovered the plugin cache, but it does not prove Chrome or Computer Use is functional.

`failure-without-later-success` means the report found a recent bundled plugin reconcile failure and did not find a later success in the scanned logs. Treat this as possible persistent cache damage until the real plugin surfaces are validated.

The timeline is intentionally bounded and sanitized. It includes event kind, plugin name, reason, error category, file name, and line number. It does not include full log lines.

### File Lock Evidence

If `plugin_cache_windows_file_lock`, `os error 5`, or `failed to remove existing plugin cache entry` appears near a Codex update, Chrome or the extension host may have locked a file that Codex tried to replace.

If the Computer Use helper file is missing from all versioned plugin cache folders, the bundled plugin cache may be incomplete.

If all files exist but the plugin still fails, the next step is functional validation:

- Chrome: confirm the actual Codex Chrome extension backend can list or use tabs.
- Computer Use: confirm the official Computer Use helper can list Windows apps.

Do not call the issue fixed from this report alone.

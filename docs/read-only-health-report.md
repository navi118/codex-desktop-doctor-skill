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

If `plugin_cache_windows_file_lock`, `os error 5`, or `failed to remove existing plugin cache entry` appears near a Codex update, Chrome or the extension host may have locked a file that Codex tried to replace.

If the Computer Use helper file is missing from all versioned plugin cache folders, the bundled plugin cache may be incomplete.

If all files exist but the plugin still fails, the next step is functional validation:

- Chrome: confirm the actual Codex Chrome extension backend can list or use tabs.
- Computer Use: confirm the official Computer Use helper can list Windows apps.

Do not call the issue fixed from this report alone.

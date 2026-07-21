# Read-Only Health Report

This project includes an optional read-only PowerShell report helper:

```powershell
.\scripts\codex-desktop-health-report.ps1
```

The helper prints a JSON report to stdout. It does not repair files, delete caches, reinstall plugins, edit configuration, launch Chrome, or control Windows apps.

Current report schema: `4`.

To save a report for an issue:

```powershell
.\scripts\codex-desktop-health-report.ps1 > codex-desktop-health-report.json
```

## What It Collects

- Windows version basics.
- Installed Codex AppX package information when available.
- Selected non-secret Codex `config.toml` fields, including `runCodexInWindowsSubsystemForLinux`, the `openai-bundled` marketplace source, and Browser/Chrome/Computer Use enabled flags.
- Whether the default Codex plugin cache paths exist.
- Bundled plugin names and version directories under `openai-bundled`.
- Chrome Native Messaging registry and manifest state for `com.openai.codexextension`.
- Whether the Chrome native host path appears to point into mutable Codex bundled plugin cache locations.
- Running Chrome extension host process paths when available.
- Whether the expected Chrome native host and Computer Use client script exist in versioned plugin folders.
- Process counts for Codex, Chrome, Chrome extension host, and Computer Use helper.
- Counts of common error strings in recent Codex Desktop app logs.
- A bounded bundled plugin reconcile timeline.
- Whether a recent reconcile failure was followed by a later successful reconcile.

The log scan is intentionally bounded by recent files and does not scan Codex thread session files. Pattern counting reads each scanned log file once and checks all known diagnostic strings during that pass, so larger log directories do not multiply work by the number of patterns.

## What It Avoids

- It does not include full log lines.
- It does not scan Codex thread session files.
- It replaces the user profile path with `%USERPROFILE%`.
- It reports only selected non-secret `config.toml` keys, not the full config file.
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
Browser is not available: extension
Browser is not available: chrome
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

### Config Summary

The report includes `codexConfig`.

Useful fields:

```text
codexConfig.exists
codexConfig.runCodexInWindowsSubsystemForLinux
codexConfig.openaiBundledMarketplace.source
codexConfig.openaiBundledMarketplace.sourceExists
codexConfig.openaiBundledMarketplace.sourceLooksDefaultTmp
codexConfig.openaiBundledMarketplace.sourceLooksStableUserCopy
codexConfig.bundledPluginConfig.browser@openai-bundled.enabled
codexConfig.bundledPluginConfig.chrome@openai-bundled.enabled
codexConfig.bundledPluginConfig.computer-use@openai-bundled.enabled
```

If a plugin is enabled in `config.toml` but the current thread still has no callable backend, treat that as a runtime exposure or capability-loading problem. Do not call the plugin healthy from config alone.

### File Lock Evidence

If `plugin_cache_windows_file_lock`, `os error 5`, or `failed to remove existing plugin cache entry` appears near a Codex update, Chrome or the extension host may have locked a file that Codex tried to replace.

If the Computer Use client script is missing from all versioned plugin cache folders, the bundled plugin cache may be incomplete.

If all files exist but the plugin still fails, the next step is functional validation:

- Chrome: confirm the actual Codex Chrome extension backend can list or use tabs.
- Computer Use: confirm the official Computer Use client can list Windows apps through the native pipe.

Do not call the issue fixed from this report alone.

### Chrome Native Messaging

The report includes `chromeNativeMessaging`.

It reads the native host registry entry through PowerShell registry APIs instead of parsing localized `reg.exe` output. This avoids false negatives on non-English Windows systems where the default registry value label may not appear as literal `(Default)`.

Useful fields:

```text
chromeNativeMessaging.registry.exists
chromeNativeMessaging.registry.defaultValuePresent
chromeNativeMessaging.registry.manifestPath
chromeNativeMessaging.manifest.exists
chromeNativeMessaging.manifest.hostPath
chromeNativeMessaging.manifest.hostPathExists
chromeNativeMessaging.manifest.hostPathLooksMutableCache
chromeNativeMessaging.runningExtensionHosts
```

`hostPathLooksMutableCache = true` means the manifest path appears to point into a Codex bundled plugin cache or marketplace path. That is useful evidence for Windows file-lock risk, because Chrome may keep the native host executable running while Codex later tries to reconcile or replace the same cache tree.

A present registry key, valid manifest, existing host path, and running `extension-host.exe` process still do not prove Chrome is usable from Codex. The final validation is whether the actual Chrome extension backend is exposed and can list or control tabs.

---
name: Chrome or Computer Use failure
about: Report a Windows Codex Desktop Chrome or Computer Use plugin problem
title: "[Windows] "
labels: ["windows", "chrome", "computer-use"]
assignees: []
---

Before opening: this project only accepts real Windows Codex Desktop cases with sanitized evidence. Do not paste full private logs, tokens, email addresses, project paths, or screenshots containing secrets.

## Scope Check

Which surface is affected?

- [ ] Chrome plugin
- [ ] Computer Use plugin
- [ ] Both Chrome and Computer Use
- [ ] Plugin appears enabled, but the current thread cannot load/use it

## What Happened

Describe the user-visible symptom.

Example:

```text
After updating Codex Desktop, @Chrome no longer controls Chrome.
Computer Use also says helper paths are unavailable.
```

## Environment

- Windows version:
- Codex Desktop version:
- Codex install/update date if known:
- Chrome version:
- Was Chrome open during Codex update? yes / no / unknown

## Timing

- [ ] Started after Codex update
- [ ] Started after enabling/disabling a plugin
- [ ] Started after restarting Codex
- [ ] Started after Chrome was left open
- [ ] Unknown

## Chrome Checks

- [ ] Chrome is installed
- [ ] Chrome is running
- [ ] Codex Chrome Extension is installed
- [ ] Codex Chrome Extension is enabled
- [ ] Native host manifest was checked
- [ ] The actual Chrome extension backend was tested

## Computer Use Checks

- [ ] Computer Use plugin is enabled
- [ ] Computer Use helper path exists
- [ ] Computer Use can list apps
- [ ] Computer Use native pipe logs were checked

## Relevant Log Excerpts

Paste only short sanitized excerpts.

```text
Replace private paths with %USERPROFILE% or <redacted>.
```

Useful strings include:

```text
plugin_cache_windows_file_lock
bundled_plugins_reconcile_failed
os error 5
missing-helper-path
Windows Computer Use helper paths are unavailable
native pipe startup failed
Cannot communicate with the Codex Chrome Extension
```

## Optional Read-Only Health Report

If you used the read-only helper, paste the relevant summary only. Do not paste private full logs.

```powershell
.\scripts\codex-desktop-health-report.ps1
```

- Health report attached or summarized? yes / no
- `logs.reconcileAssessment.status`:
- Any nonzero error pattern counts:
- Any missing expected helper files:

## Expected Behavior

What should have happened?

## Validation Result

What proves it is still broken or fixed?

- Chrome:
- Computer Use:
- Current thread capability:

## Notes

Anything else that may matter?

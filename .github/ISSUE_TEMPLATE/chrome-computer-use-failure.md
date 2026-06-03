---
name: Chrome or Computer Use failure
about: Report a Windows Codex Desktop Chrome or Computer Use plugin problem
title: "[Windows] "
labels: ["windows", "chrome", "computer-use"]
assignees: []
---

## Scope Check

Which surface is affected?

- [ ] Chrome plugin
- [ ] Computer Use plugin
- [ ] Both Chrome and Computer Use

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
- Chrome version:
- Was Chrome open during Codex update? yes / no / unknown

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

## Expected Behavior

What should have happened?

## Notes

Anything else that may matter?

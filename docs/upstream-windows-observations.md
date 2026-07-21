# Upstream Windows Observations

This document tracks public upstream observations from `openai/codex` issues that are relevant to Codex Desktop Doctor.

These observations are not official OpenAI confirmation. Treat them as external reports that help shape safer diagnostic questions.

Last checked: 2026-06-15.

## Why This Matters

Codex Desktop Doctor should not depend only on one maintainer machine. Public upstream reports help identify which Windows failures are repeatable across users, versions, regions, and installation shapes.

The project uses these observations to improve diagnostic coverage, not to add broad automatic repair behavior.

## Observation Summary

| Upstream issue | Signal | Project impact |
| --- | --- | --- |
| [openai/codex#24296](https://github.com/openai/codex/issues/24296) | Chrome native host can run from mutable bundled plugin cache paths, and Chrome extension backend may still fail to appear even when registry, manifest, and `extension-host.exe` exist. | Check Chrome Native Messaging registry and manifest state directly. Do not assume a running native host proves the Chrome backend is exposed. |
| [openai/codex#25391](https://github.com/openai/codex/issues/25391) | Multiple Windows users report Computer Use `missing-helper-path`, missing native pipe injection, Chrome and Computer Use disappearing together, WSL-vs-Windows runtime differences, and cache/marketplace file-lock interactions. | Separate file presence from runtime capability. Check bundled cache, marketplace state, process locks, and whether the current thread actually receives Computer Use pipe metadata. |
| [openai/codex#25393](https://github.com/openai/codex/issues/25393) | Automations sidebar count badge can disappear while automations still exist and run. | Not in current diagnosis scope. Track as a UI state bug, not a Chrome or Computer Use plugin failure. |

## Chrome Native Host And Backend Exposure

`openai/codex#24296` includes an external Windows report on Codex Desktop `26.609.x` where:

- the HKCU Native Messaging registry key exists;
- the manifest exists;
- the manifest points to a bundled `extension-host.exe`;
- Chrome has launched `extension-host.exe`;
- but the Codex browser runtime still only exposes the in-app browser backend, not the Chrome extension backend.

It also notes a useful localization pitfall: a diagnostic script that parses `reg query ... /ve` output may misread the default registry value on non-English Windows because the localized `(Default)` label can appear as mojibake.

Diagnostic implication:

- Prefer PowerShell registry APIs or another structured registry reader over parsing localized `reg.exe` display text.
- Report whether the native host manifest path and manifest `path` point into mutable Codex cache locations.
- Treat `extension-host.exe is running` as evidence, not proof. The real validation is whether the Chrome extension backend is exposed and can list or use tabs.

## Computer Use Native Pipe And Bundled Plugin State

`openai/codex#25391` contains several external Windows reports that are relevant to this project:

- Computer Use can work earlier in a session and later fail with `missing-helper-path`.
- Logs can show a successful native pipe startup followed later by helper paths changing to missing.
- Plugin files can exist on disk while the active runtime still does not receive `SKY_CUA_NATIVE_PIPE_DIRECTORY`.
- Chrome and Computer Use can disappear from the UI together after bundled plugin or cache problems.
- WSL mode can fail differently from Windows-native mode.
- Non-C-drive Codex installs and mutable `.codex\.tmp\bundled-marketplaces\openai-bundled` paths may introduce additional failure shapes.

Diagnostic implication:

- Do not classify the issue as "plugin not installed" just because Computer Use cannot start.
- Check whether the official Computer Use client script and expected plugin files exist, whether the bundled marketplace mirror is complete, and whether the current runtime actually receives native pipe metadata.
- Avoid treating third-party workaround snippets as project policy. They are useful evidence, but this project should remain diagnostic-first and preserve official Codex default paths unless a repair is explicitly approved.

## Out Of Scope For Now

`openai/codex#25393` is useful evidence that Codex Desktop UI state can drift from underlying automation state, but it is not a Chrome, Computer Use, bundled plugin cache, or current-thread capability-loading issue.

It should not expand the current project scope unless repeated reports show a safe, repeatable diagnostic path.

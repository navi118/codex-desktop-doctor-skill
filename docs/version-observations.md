# Version Observations

This document tracks sanitized Windows Codex Desktop build and bundled plugin path observations.

These observations are not official OpenAI compatibility statements. They are maintainer or user reports used to avoid hardcoded version assumptions and to keep diagnostics aligned with real installed layouts.

Do not paste full logs, private paths, tokens, emails, prompts, or thread content into this document.

## Observations

| Date | Source | Windows | Codex Desktop | Bundled plugin versions | Important path shape | Diagnostic note |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-06-30 | Maintainer Windows machine, sanitized read-only health report | Windows 11 Pro, 10.0.26200, x64 | `OpenAI.Codex_26.623.8305.0_x64__2p2nqsd0c76g0` | Browser `26.623.61825`; Chrome `26.623.61825` plus `latest`; Computer Use `26.623.61825` | `openai-bundled` marketplace source under `\\?\%USERPROFILE%\.codex\.tmp\bundled-marketplaces\openai-bundled`; plugin cache under `%USERPROFILE%\.codex\plugins\cache\openai-bundled` | Computer Use plugin uses `scripts\computer-use-client.mjs` as the official client entry point; do not require the older standalone `codex-computer-use.exe` path. Chrome native messaging registry, manifest, and host path were present, with the host path pointing into mutable bundled plugin cache state. A bounded 40-file log scan classified recent reconcile evidence as `transient-failure-followed-by-success` with file-lock evidence, so file checks still require functional Chrome or Computer Use validation before calling the system healthy. |

## Interpretation Rules

- A Codex Desktop AppX version and a bundled plugin version can differ. Do not assume the app package version and plugin cache version are the same.
- A `latest` alias in a plugin cache is path evidence, not proof that the current thread can use that plugin.
- For Chrome, `extension-host.exe` presence is useful evidence, but the real validation is whether the Chrome extension backend is exposed and can list or control tabs.
- For Computer Use, `scripts\computer-use-client.mjs` presence is useful file evidence, but the real validation is whether the official client can list apps through the native pipe.
- If a newer observation changes file layout expectations, update `scripts/codex-desktop-health-report.ps1`, `docs/read-only-health-report.md`, and the Computer Use references together.

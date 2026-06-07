# Maintainer Notes

## Current Scope

This project intentionally starts with the Windows Codex Desktop surfaces that produce the clearest desktop-control failures:

- Chrome
- Computer Use
- closely related bundled plugin cache and current-thread capability loading problems

The project should not cover GitHub, Gmail, Drive, Photoshop, Cloudflare, automations, model routing, billing, or general Codex config cleanup until there is repeated evidence and a clear validation method. Narrow scope makes the skill easier to trust and easier to maintain.

## Why No Repair Script In v0.1

Different Windows machines may have different Codex versions, install paths, cache state, Chrome profiles, extension state, language settings, and app permissions. A universal script can easily damage user state if it guesses wrong.

The first version is therefore an agent skill:

- It teaches evidence collection.
- It explains the failure model.
- It defines safe repair boundaries.
- It forces validation against the real Chrome and Computer Use surfaces.

Scripts can be added later only for narrow, tested, reversible operations.

## Good Issues To Collect

When users report problems, ask for sanitized evidence:

- Codex Desktop version.
- Windows version.
- Whether Chrome was open during update.
- Recent log lines containing `plugin_cache_windows_file_lock`, `os error 5`, `missing-helper-path`, or native pipe failures.
- Whether Chrome extension and native host checks pass.
- Whether Computer Use can list apps through the official client.

Do not ask users to upload full logs if they may contain private paths, thread titles, or personal data.

## Release Bar

Before publishing a release:

- `SKILL.md` validates.
- README clearly says the supported scope and non-goals.
- Examples explain why failures happen.
- Safety boundaries forbid deleting `.codex` or pretending unrelated automation is a repair.
- New claims are backed by an issue, local reproduction, sanitized logs, or a documented maintainer case.
- Release notes explain what changed and what evidence motivated the change.

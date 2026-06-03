# Maintainer Notes

## Initial Scope

This project intentionally starts with only two Codex Desktop bundled plugins:

- Chrome
- Computer Use

The first release should not cover GitHub, Gmail, Drive, Photoshop, Cloudflare, automations, model routing, or general Codex config cleanup. Narrow scope makes the skill easier to trust and easier to maintain.

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

Before publishing v0.1.0:

- `SKILL.md` validates.
- README clearly says scope is Chrome and Computer Use only.
- Examples explain why failures happen.
- Safety boundaries forbid deleting `.codex` or pretending unrelated automation is a repair.

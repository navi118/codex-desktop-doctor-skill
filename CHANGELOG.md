# Changelog

## v0.2.8 - 2026-06-17

- Extend the read-only health report with selected non-secret Codex `config.toml` evidence.
- Report `openai-bundled` marketplace source state and Browser/Chrome/Computer Use enabled flags.
- Improve user-profile path sanitization for Windows extended-length paths such as `\\?\C:\Users\...`.
- Keep the helper diagnostic-only; no config editing or repair automation was added.

## v0.2.7 - 2026-06-15

- Add upstream Windows observations from public `openai/codex` issue reports.
- Document related Chrome Native Messaging, Chrome backend exposure, Computer Use native pipe, and bundled plugin cache failure shapes.
- Extend the read-only health report with Chrome Native Messaging registry and manifest checks.
- Keep the project diagnostic-only; no repair automation was added.

## v0.2.6 - 2026-06-14

- Add sanitized visual examples for non-technical users.
- Show mock skill-folder layout, plugin failure symptoms, good diagnostic summaries, and safe issue excerpts.
- Respond to external documentation issue #7.

## v0.2.5 - 2026-06-10

- Add a one-minute quick start near the top of the README for first-time users.
- Respond to external documentation issue #8.

## v0.2.4 - 2026-06-09

- Add a beginner FAQ for common project scope, safety, privacy, and issue-reporting questions.
- Respond to external documentation issue #5.
- Clarify the difference between diagnosis and repair near the top of the README.
- Respond to external documentation issue #6.

## v0.2.3 - 2026-06-09

- Add health report reconcile timeline extraction for bundled plugin update events.
- Distinguish transient reconcile failures followed by success from failures without later success.
- Add a core Chrome update file-lock recovery example based on a maintainer-reported case.
- Expand documentation for interpreting `plugin_cache_windows_file_lock` without over-claiming persistent damage.
- Respond to maintainer-reported core issue #4.

## v0.2.2 - 2026-06-09

- Add a read-only PowerShell health report helper for safer issue preparation.
- Document what the report collects, what it avoids, and how to interpret common error patterns.
- Keep the helper diagnostic-only: it does not repair, delete, reinstall, edit config, scan thread sessions, or include full log lines.
- Respond to external feature request #3.

## v0.2.1 - 2026-06-07

- Add a non-technical quick diagnosis checklist for first-time Windows Codex Desktop users.
- Link the checklist from the README so users can start without reading logs first.
- Keep the checklist diagnostic-only; no repair scripts or destructive steps were added.

## v0.2.0 - 2026-06-07

- Reposition the project from a narrow bug workaround to a Windows Codex Desktop diagnostic skill.
- Clarify supported failure areas: Chrome, Computer Use, bundled plugin cache, and current-thread capability loading.
- Add real issue collection guidance for maintainers and users.
- Add OpenAI OSS application draft notes.
- Add roadmap and supported failure documentation.
- Add more example cases for plugin cache reconciliation and thread capability loading.

## v0.1.0 - 2026-06-03

- Initial public release.
- Add Codex skill metadata and core workflow.
- Add Chrome and Computer Use diagnosis references.
- Add safety boundaries against destructive cache repairs.
- Add initial examples for Chrome file lock and Computer Use missing helper path.

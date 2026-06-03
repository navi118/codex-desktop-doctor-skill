# Contributing

Thanks for helping improve Codex Desktop Doctor.

## Scope

For the first release, this project only accepts cases about Codex Desktop on Windows where one of these surfaces is affected:

- Chrome plugin
- Computer Use plugin

Please do not open issues for GitHub, Gmail, Drive, Photoshop, Cloudflare, automations, model selection, billing, or general Codex support unless the scope of this project has been expanded.

中文：第一版只收 Chrome 插件和 Computer Use 电脑操作插件的问题。其他连接器先不收，避免项目范围失控。

## Good Bug Reports

Good reports include sanitized evidence:

- Windows version.
- Codex Desktop version if visible.
- Whether Chrome was open during Codex update.
- Whether the Codex Chrome Extension is installed and enabled.
- Whether Computer Use can list apps.
- Short log excerpts containing relevant errors.

Relevant error strings include:

```text
plugin_cache_windows_file_lock
os error 5
Access is denied
bundled_plugins_reconcile_failed
missing-helper-path
Windows Computer Use helper paths are unavailable
computer-use native pipe startup failed
Cannot communicate with the Codex Chrome Extension
```

## Privacy

Do not post full logs if they include personal paths, thread titles, project names, email addresses, or tokens. Prefer short excerpts with private values replaced by placeholders such as:

```text
%USERPROFILE%
<thread-id>
<project-name>
```

## Maintainer Rule

When improving the skill, preserve its safety stance:

- Diagnose before repair.
- Explain why the failure happened.
- Do not add broad repair scripts without tests and rollback logic.
- Do not tell agents to delete `.codex` wholesale.
- Do not use unrelated automation as proof that Chrome or Computer Use is fixed.

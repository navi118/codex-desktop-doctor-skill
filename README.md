# Codex Desktop Doctor Skill

Codex Desktop Doctor is an evidence-first Codex Skill for diagnosing **Codex Desktop on Windows** when desktop plugins, capability loading, bundled plugin cache, Chrome control, or Computer Use stop working.

中文说明：这是给 Codex Agent 用的 Windows 桌面端诊断 Skill。第一阶段重点覆盖 Chrome 和 Computer Use，因为这两个能力最容易暴露 Codex Desktop、插件缓存、线程能力加载、Windows 文件锁之间的问题。

## Why This Exists

Codex Desktop failures are easy to misdiagnose. Chrome can open normally while the Codex Chrome plugin is broken. PowerShell can launch apps while Computer Use is unavailable. Plugin files can exist on disk while the current thread still cannot load the backend.

This skill teaches agents to collect evidence, explain the likely root cause, stay inside safe repair boundaries, and validate the real Codex surface before saying a problem is fixed.

中文：这个项目的核心价值不是“一键乱修”，而是让 Agent 不糊弄。看证据、说原因、做安全边界内的处理，最后用真实 Chrome/Computer Use 能力验证。

## Supported Failure Areas

Use this skill when Codex Desktop on Windows shows symptoms like:

- Chrome plugin is enabled but `@Chrome` cannot actually control Chrome.
- Computer Use is enabled but Windows apps cannot be controlled.
- Chrome and Computer Use disappear or fail after a Codex update.
- Logs mention `plugin_cache_windows_file_lock`, `os error 5`, `missing-helper-path`, or native pipe startup failure.
- Chrome extension appears installed, but Codex cannot communicate with it.
- A plugin appears enabled in settings, but the current thread cannot load or use the related capability.
- Normal browser or shell automation works, but the official Codex plugin surface still fails.

The first release focuses on Chrome and Computer Use. Broader plugin, skill, MCP, and connector diagnosis may be added only when there is real evidence and repeatable validation.

## Quick Checklist

If you are not sure where to start, use the plain-language checklist first:

- [docs/non-technical-checklist.md](docs/non-technical-checklist.md)

中文：如果你不是程序员，先看这个快速清单。它会帮你判断是 Chrome、Computer Use、当前线程能力加载，还是需要进一步看日志。

## Common Root Causes

Codex Desktop uses bundled plugin files under the user's Codex cache. On Windows, a running executable or native host can keep a file locked. If Codex updates or reconciles bundled plugins while Chrome or a native host still holds a file handle, Windows may return access denied. That can leave the bundled plugin cache in a partial state.

When this happens, Chrome can fail because the extension or native host handshake is broken. Computer Use can fail at the same time because its helper path or native pipe setup depends on bundled plugin files from the same cache family.

中文：核心原因通常不是“用户没装好”，而是 Windows 文件锁加 Codex 更新/插件同步流程，让缓存处在半更新状态。Chrome 先卡住，Computer Use 也可能被牵连。

## What This Skill Does Well

- Teaches an agent what evidence to collect before changing anything.
- Explains how Chrome, the Codex Chrome Extension, native host, plugin cache, and Computer Use helper paths relate.
- Separates local cache failures from thread capability loading problems.
- Defines safe repair boundaries so agents do not delete `.codex` or fake a repair with unrelated automation.
- Requires functional validation before saying the issue is fixed.
- Helps maintainers collect real, sanitized issue reports from Windows Codex Desktop users.

## What This Skill Does Not Do

- It does not include a universal PowerShell repair script.
- It does not diagnose GitHub, Gmail, Google Drive, Photoshop, Cloudflare, billing, model routing, or general account support yet.
- It does not tell agents to modify arbitrary global config.
- It does not treat `gh` CLI, shell app launching, or normal Chrome browsing as proof that the Codex plugins work.
- It does not bypass user approval for file-changing repairs.

## Install

Clone this repository, then copy the `codex-desktop-doctor` skill folder into your Codex skills directory:

```powershell
git clone https://github.com/navi118/codex-desktop-doctor-skill.git
Set-Location .\codex-desktop-doctor-skill
$dest = Join-Path $env:USERPROFILE ".codex\skills\codex-desktop-doctor"
Copy-Item -Recurse -Force ".\codex-desktop-doctor" $dest
```

Then start a new Codex thread and ask:

```text
Use codex-desktop-doctor to diagnose why Chrome or Computer Use stopped working after a Codex update.
```

Example requests:

```text
Use codex-desktop-doctor to check why @Chrome opens but cannot control Chrome.
```

```text
Use codex-desktop-doctor to diagnose Computer Use missing-helper-path on Windows.
```

```text
Use codex-desktop-doctor to decide whether this is plugin cache damage or a current-thread capability loading problem.
```

## Real Issue Reports

Real issues are valuable when they include sanitized evidence:

- Windows version and Codex Desktop version.
- Which surface failed: Chrome, Computer Use, or both.
- Short log excerpts with private values replaced.
- What validation passed or failed.
- Whether the problem happened after update, restart, plugin enablement, or Chrome being left open.

Do not create fake issues or fake logs. If a maintainer opens an issue from their own machine, label it clearly as a maintainer-reported case and include only sanitized evidence.

See [docs/real-issue-playbook.md](docs/real-issue-playbook.md).

## Repository Layout

```text
codex-desktop-doctor-skill/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── ROADMAP.md
├── .github/ISSUE_TEMPLATE/
│   └── chrome-computer-use-failure.md
├── codex-desktop-doctor/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/
│       ├── chrome-and-computer-use.md
│       ├── evidence-patterns.md
│       └── safe-repair-boundaries.md
├── docs/
│   ├── decision-tree.md
│   ├── maintainer-notes.md
│   ├── non-technical-checklist.md
│   ├── openai-oss-application.md
│   ├── real-issue-playbook.md
│   └── supported-failures.md
└── examples/
    ├── chrome-file-lock-after-update.md
    ├── computer-use-missing-helper-path.md
    ├── plugin-cache-reconcile-failure.md
    └── thread-capability-not-loaded.md
```

## Safety Policy

The skill is intentionally conservative:

- Diagnose first.
- Explain root cause in plain language.
- Only repair when evidence points to default Codex bundled plugin cache state.
- Back up before changing files.
- Preserve official Codex default paths.
- Validate with the real Chrome or Computer Use surface after repair.

中文：这个项目的价值不是“强行一键修”，而是让 Agent 不乱来。能修的修，不能本地修的明确说清楚。

## Project Roadmap

For a compact troubleshooting path, see [docs/decision-tree.md](docs/decision-tree.md).

For planned scope and release direction, see [ROADMAP.md](ROADMAP.md).

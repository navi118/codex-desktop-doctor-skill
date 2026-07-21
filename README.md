# Codex Desktop Doctor Skill

Codex Desktop Doctor is an evidence-first Codex Skill for diagnosing **Codex Desktop on Windows** when desktop plugins, capability loading, bundled plugin cache, Chrome control, or Computer Use stop working.

中文说明：这是给 Codex Agent 用的 Windows 桌面端诊断 Skill。第一阶段重点覆盖 Chrome 和 Computer Use，因为这两个能力最容易暴露 Codex Desktop、插件缓存、线程能力加载、Windows 文件锁之间的问题。

## One-Minute Quick Start

Use this skill when Codex Desktop on Windows can no longer use Chrome or Computer Use correctly, especially after a Codex update, restart, plugin enablement, or bundled plugin cache error.

Install:

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

中文：如果 Windows 上的 Codex Desktop 更新后，Chrome 或 Computer Use 不能用了，先装这个 Skill，再开新线程让它按证据诊断。它不会自动乱修，也不会把普通 Chrome 能打开当成 Codex 插件已修好。

## Diagnosis vs Repair

This project separates diagnosis from repair:

- Diagnosis means collecting evidence, identifying the likely cause, and explaining what should be checked next.
- Repair means changing files, plugin cache state, configuration, or other Codex Desktop state.
- Repairs require stronger evidence, a backup or rollback path, and explicit user approval.
- Opening Chrome, launching a Windows app, or running shell automation is not proof that the official Codex Chrome or Computer Use plugin surface is fixed.

中文：诊断是先找证据、判断原因、说明下一步；修复才是改文件、改缓存或改配置。修复必须有更强证据、备份/回滚方式，并得到用户明确同意。Chrome 能打开、Windows 应用能启动，不等于 Codex 官方插件真的修好了。

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

## FAQ

For common beginner questions, see:

- [docs/faq.md](docs/faq.md)

It explains what this project is, what it does not repair automatically, what information is safe to include in an issue, and why Chrome opening normally does not prove the Codex Chrome plugin works.

中文：常见问题看 FAQ。它会解释这个项目是不是官方项目、会不会自动修、issue 里什么信息能贴，以及为什么 Chrome 能打开不等于 Codex Chrome 插件正常。

## Visual Examples

For sanitized mock screenshots and safe issue-report examples, see:

- [docs/visual-examples.md](docs/visual-examples.md)

中文：如果你不确定 Skill 文件夹应该长什么样、哪些错误信息能贴到 issue、哪些截图或日志不安全，看这个脱敏示意页。

## Upstream Windows Observations

For related public `openai/codex` Windows reports that inform this project, see:

- [docs/upstream-windows-observations.md](docs/upstream-windows-observations.md)

These are external observations, not official OpenAI confirmation. They help track repeated Chrome, Computer Use, bundled plugin cache, and native-pipe failure shapes.

## Read-Only Health Report

For safer issue preparation, this repository includes a read-only PowerShell report helper:

```powershell
.\scripts\codex-desktop-health-report.ps1
```

It prints JSON to stdout and does not repair, delete, reinstall, or edit Codex state. It checks Windows/Codex version basics, selected non-secret `config.toml` plugin/marketplace settings, default bundled plugin cache paths, Chrome Native Messaging registry/manifest state, Chrome native host and Computer Use client-script presence, counts known error patterns in recent Codex Desktop app logs, and summarizes whether bundled plugin reconcile failures were followed by later success.

See [docs/read-only-health-report.md](docs/read-only-health-report.md).

Observed Windows Codex Desktop builds and bundled plugin path shapes are tracked in [docs/version-observations.md](docs/version-observations.md). Use those observations as diagnostic context, not as hardcoded version requirements.

## Common Root Causes

Codex Desktop uses bundled plugin files under the user's Codex cache. On Windows, a running executable or native host can keep a file locked. If Codex updates or reconciles bundled plugins while Chrome or a native host still holds a file handle, Windows may return access denied. That can leave the bundled plugin cache in a partial state.

Sometimes Codex later reconciles successfully. That matters: a file-lock failure followed by `bundled_plugins_reconcile_completed` is different from a failure with no later success. This project treats the first as a transient failure that still needs functional validation, and the second as possible persistent cache damage.

When this happens, Chrome can fail because the extension or native host handshake is broken. Computer Use can fail at the same time because its helper path or native pipe setup depends on bundled plugin files from the same cache family.

中文：核心原因通常不是“用户没装好”，而是 Windows 文件锁加 Codex 更新/插件同步流程，让缓存处在半更新状态。Chrome 先卡住，Computer Use 也可能被牵连。

Even if the Chrome Native Messaging registry key, manifest, and `extension-host.exe` process exist, the Chrome extension backend still may not be exposed to the current Codex browser runtime. This project treats those as useful evidence, not final validation.

## What This Skill Does Well

- Teaches an agent what evidence to collect before changing anything.
- Explains how Chrome, the Codex Chrome Extension, native host, plugin cache, and Computer Use helper paths relate.
- Separates local cache failures from thread capability loading problems.
- Defines safe repair boundaries so agents do not delete `.codex` or fake a repair with unrelated automation.
- Requires functional validation before saying the issue is fixed.
- Helps maintainers collect real, sanitized issue reports from Windows Codex Desktop users.

## What This Skill Does Not Do

- It does not include a universal PowerShell repair script.
- It does not auto-repair from the read-only health report.
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
├── scripts/
│   ├── README.md
│   └── codex-desktop-health-report.ps1
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
│   ├── faq.md
│   ├── maintainer-notes.md
│   ├── non-technical-checklist.md
│   ├── openai-oss-application.md
│   ├── read-only-health-report.md
│   ├── real-issue-playbook.md
│   ├── supported-failures.md
│   ├── upstream-windows-observations.md
│   └── visual-examples.md
└── examples/
    ├── chrome-file-lock-after-update.md
    ├── chrome-update-file-lock-transient-recovery.md
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

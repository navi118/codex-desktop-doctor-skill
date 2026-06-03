# Codex Desktop Doctor Skill

Codex Desktop Doctor is a narrow Codex Skill for diagnosing **Chrome** and **Computer Use** failures in Codex Desktop on Windows.

中文说明：这是一个给 Codex Agent 用的故障处理 Skill，第一版只处理 Windows 上 Codex Desktop 的 Chrome 插件和 Computer Use 电脑操作插件问题。

## What It Solves

Use this skill when Codex Desktop shows symptoms like:

- Chrome plugin is enabled but `@Chrome` cannot actually control Chrome.
- Computer Use is enabled but Windows apps cannot be controlled.
- Chrome and Computer Use disappear or fail after a Codex update.
- Logs mention `plugin_cache_windows_file_lock`, `os error 5`, `missing-helper-path`, or native pipe startup failure.
- Chrome extension appears installed, but Codex cannot communicate with it.

中文：它不是万能修复器。它专门沉淀 Chrome 和 Computer Use 两类故障的判断流程、原因解释和安全修复边界。

## Why These Problems Happen

Codex Desktop uses bundled plugin files under the user's Codex cache. On Windows, a running executable or native host can keep a file locked. If Codex updates or reconciles bundled plugins while Chrome or a native host still holds a file handle, Windows may return access denied. That can leave the bundled plugin cache in a partial state.

When this happens, Chrome can fail because the extension or native host handshake is broken. Computer Use can fail at the same time because its helper path or native pipe setup depends on bundled plugin files from the same cache family.

中文：核心原因通常不是“用户没装好”，而是 Windows 文件锁加 Codex 更新/插件同步流程，让缓存处在半更新状态。Chrome 先卡住，Computer Use 也可能被牵连。

## What This Skill Does

- Teaches an agent what evidence to collect before changing anything.
- Explains how Chrome, the Codex Chrome Extension, native host, plugin cache, and Computer Use helper paths relate.
- Separates local cache failures from thread capability loading problems.
- Defines safe repair boundaries so agents do not delete `.codex` or fake a repair with unrelated automation.
- Requires functional validation before saying the issue is fixed.

## What This Skill Does Not Do

- It does not include a universal PowerShell repair script.
- It does not handle GitHub, Gmail, Google Drive, Photoshop, Cloudflare, or other connectors.
- It does not tell agents to modify arbitrary global config.
- It does not treat `gh` CLI, shell app launching, or normal Chrome browsing as proof that the Codex plugins work.

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

## Repository Layout

```text
codex-desktop-doctor-skill/
├── README.md
├── CONTRIBUTING.md
├── LICENSE
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
│   └── maintainer-notes.md
└── examples/
    ├── chrome-file-lock-after-update.md
    └── computer-use-missing-helper-path.md
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

## Diagnosis Map

For a compact troubleshooting path, see [docs/decision-tree.md](docs/decision-tree.md).

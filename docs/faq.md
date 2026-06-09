# FAQ

This FAQ answers common beginner questions about Codex Desktop Doctor.

中文：这里回答第一次看这个项目时最容易误解的问题。

## Is This An Official OpenAI Project?

No. This is a community-maintained Codex Skill, not an official OpenAI project and not an OpenAI support channel.

中文：不是 OpenAI 官方项目，也不能代表 OpenAI 客服。它是一个社区维护的诊断 Skill。

## Does This Automatically Repair Codex Desktop?

No. The project is diagnostic-first. It helps an agent collect evidence, explain the likely root cause, and decide whether a repair is appropriate.

The included health report script is read-only. It does not repair, reinstall, delete cache files, edit config, or change Codex state.

中文：不会自动修。它先判断问题在哪里。健康报告脚本只读，不会动你的 Codex 文件。

## Do I Need To Install Anything Globally?

No global package install is required for the normal skill workflow.

To use the skill, copy the `codex-desktop-doctor` folder into your Codex skills directory. To run the optional health report, use the included PowerShell script from this repository.

中文：正常使用不需要全局安装包。复制 Skill 文件夹即可。健康报告脚本也在仓库里。

## Can This Fix GitHub, Gmail, Cloudflare, Slack, Or Other Connectors?

Not yet. The current supported scope is Windows Codex Desktop diagnosis for:

- Chrome plugin control failures.
- Computer Use failures.
- Bundled plugin cache or marketplace reconcile failures.
- Current-thread capability loading failures.

中文：现在主要看 Windows 上 Codex Desktop 的 Chrome、Computer Use、插件缓存和线程能力加载问题。GitHub、Gmail、Cloudflare、Slack 这类连接器不在当前范围内。

## Chrome Opens Normally. Does That Mean The Codex Chrome Plugin Works?

No. Chrome opening normally only proves Chrome itself works. It does not prove Codex can control Chrome through the official Codex Chrome plugin surface.

The useful validation is whether Codex can actually use the Chrome capability, such as listing or controlling tabs through the plugin.

中文：Chrome 能打开不等于 Codex 的 Chrome 插件正常。真正要看的是 Codex 能不能通过官方插件控制 Chrome。

## What If The Problem Happened After A Codex Update?

A Codex update can reconcile bundled plugins. On Windows, Chrome or a native host may keep files locked while Codex tries to update or replace plugin cache files.

If the issue started after an update:

1. Start a new Codex thread.
2. Restart Codex Desktop.
3. Close Chrome fully if Chrome control is involved.
4. Run the read-only health report only if the problem persists.

中文：更新后出问题时，先新线程、重启 Codex、完全关闭 Chrome。还不行再用只读健康报告看证据。

## What Should I Do If I Cannot Read Logs?

Start with the non-technical checklist:

- [non-technical-checklist.md](non-technical-checklist.md)

Then run the read-only health report:

```powershell
.\scripts\codex-desktop-health-report.ps1
```

You can share the short report summary or short error strings in an issue. Do not paste full private logs.

中文：不会看日志就先看快速清单，再跑只读健康报告。发 issue 时贴摘要，不要贴完整隐私日志。

## What Information Is Safe To Include In An Issue?

Usually safe:

- Windows version.
- Codex Desktop version.
- Which surface failed: Chrome, Computer Use, or both.
- Whether it happened after update, restart, plugin enablement, or leaving Chrome open.
- Short error strings such as `plugin_cache_windows_file_lock`, `missing-helper-path`, or `bundled_plugins_reconcile_failed`.
- Whether a later `bundled_plugins_reconcile_completed` appeared.

Do not include:

- Tokens, API keys, passwords, or cookies.
- Email addresses.
- Full private logs.
- Private project names or file contents.
- Full thread IDs, thread titles, or conversation content.
- Full personal paths if they reveal private names or project names.

中文：可以贴版本、失败的是 Chrome 还是 Computer Use、短错误词、是否更新后发生。不要贴密钥、邮箱、完整日志、私有项目内容和完整个人路径。

## When Should I Stop And Avoid Repair Attempts?

Stop at diagnosis when:

- A new Codex thread works.
- The issue is only GitHub, Gmail, billing, account access, or another unsupported connector.
- You only proved Chrome or a Windows app can open normally.
- There is no evidence of bundled plugin cache, helper path, or capability loading failure.

中文：如果新线程能用，或者问题根本不是 Chrome/Computer Use/插件缓存，就不要乱修。

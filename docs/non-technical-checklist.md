# Non-Technical Quick Diagnosis Checklist

Use this checklist before reading logs or changing files. It is for Windows Codex Desktop users who are trying to understand whether Chrome, Computer Use, plugin cache, or the current thread is the likely problem.

中文：这是非程序员也能先看的快速清单。它只帮助判断方向，不会要求你直接改系统文件。

If you want to see safe mock examples before opening an issue, use:

- [visual-examples.md](visual-examples.md)

中文：如果你想先看脱敏示意图，确认文件夹、错误信息和 issue 内容应该怎么写，可以看这个示例页。

## 1. What Is Actually Broken?

Pick the closest symptom:

- Chrome opens normally, but Codex cannot control Chrome.
- Computer Use is enabled, but Codex cannot control Windows apps.
- Both Chrome and Computer Use failed after a Codex update or restart.
- The plugin looks enabled in Codex settings, but this thread cannot use it.
- You are not sure; Codex only says the tool or backend is unavailable.

## 2. Do Not Treat These As Proof

These checks are useful, but they do not prove the Codex plugin works:

- Chrome opens from the Start menu.
- A webpage loads in Chrome.
- PowerShell can launch an app.
- Another browser automation method works.
- The plugin folder exists on disk.

The real question is whether the official Codex Chrome or Computer Use surface works.

## 3. Try The Low-Risk Refresh First

Before file changes, try:

1. Start a new Codex thread.
2. Restart Codex Desktop.
3. If Chrome is involved, close Chrome fully and reopen it.
4. Re-check whether the same Codex capability is available.

If the new thread works, the old thread probably had a capability-loading problem. Do not rebuild plugin cache just for that.

## 4. When To Look Deeper

Look deeper when:

- The same problem appears in a new thread.
- Restarting Codex does not help.
- Chrome and Computer Use broke at the same time.
- The error mentions `missing-helper-path`.
- The error mentions `plugin_cache_windows_file_lock`.
- Recent logs mention `bundled_plugins_reconcile_failed`.

These signs may point to bundled plugin cache or helper path damage.

## 5. What To Collect For An Issue

If you open an issue, include only sanitized information:

- Windows version.
- Codex Desktop version.
- Which surface failed: Chrome, Computer Use, or both.
- Whether it started after an update, restart, or plugin change.
- Short error strings, not full private logs.
- What you tried: new thread, restart, closing Chrome, or validation attempt.

Replace private paths, emails, project names, thread titles, and tokens with placeholders.

## 6. When Not To Repair

Do not repair cache or edit files when:

- Only one old thread lacks the tool but a new thread works.
- You have not checked whether Codex Desktop was restarted.
- The issue is GitHub, Gmail, Drive, Cloudflare, billing, or account access.
- You only proved Chrome or a Windows app opens normally.

Stop at diagnosis unless the evidence points to Codex Desktop plugin state.

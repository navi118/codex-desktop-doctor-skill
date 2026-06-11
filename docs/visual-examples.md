# Sanitized Visual Examples

These examples are text mockups, not real screenshots. They show what to look for without exposing private paths, email addresses, thread titles, tokens, or full logs.

中文：这些是脱敏文字示意图，不是真实截图。它们帮助非技术用户理解该看哪里、贴什么证据、不要贴什么隐私。

## 1. Where The Skill Folder Goes

After installation, the folder should look like this:

```text
%USERPROFILE%\.codex\skills\
└── codex-desktop-doctor\
    ├── SKILL.md
    ├── agents\
    │   └── openai.yaml
    └── references\
        ├── chrome-and-computer-use.md
        ├── evidence-patterns.md
        └── safe-repair-boundaries.md
```

Good signs:

- The folder name is exactly `codex-desktop-doctor`.
- `SKILL.md` is directly inside that folder.
- The `references` files are still inside the skill folder.

Common mistake:

```text
%USERPROFILE%\.codex\skills\
└── codex-desktop-doctor-skill\
    └── codex-desktop-doctor\
        └── SKILL.md
```

That nested layout may stop Codex from discovering the skill. Copy the inner `codex-desktop-doctor` folder into `skills` instead.

## 2. Chrome Failure Symptom

A normal browser window opening is not enough proof that the Codex Chrome plugin works.

Example user-visible symptom:

```text
Codex thread:

User: Use @Chrome to inspect the current tab.
Codex: Chrome is unavailable, or the Chrome backend cannot be reached.

Windows:

Chrome still opens normally from the Start menu.
```

Useful diagnosis:

- Chrome itself may be fine.
- The Codex Chrome plugin, extension bridge, native host, or current-thread capability loading may be broken.
- Validate the official Codex Chrome surface before saying Chrome is fixed.

## 3. Computer Use Failure Symptom

Computer Use can be broken even when Windows apps open normally.

Example user-visible symptom:

```text
Codex thread:

User: Use @Computer to control Notepad.
Codex: Computer Use helper paths are unavailable.

Windows:

Notepad opens normally from the Start menu.
```

Useful diagnosis:

- PowerShell or Windows launching an app is not proof that Computer Use works.
- The useful check is whether the official Computer Use surface can list or inspect apps.

## 4. Good Diagnostic Result

A good result is short, evidence-based, and clear about uncertainty.

```text
Diagnosis summary:

- Affected surface: Chrome and Computer Use.
- Timing: started after Codex Desktop update.
- Relevant short errors:
  - plugin_cache_windows_file_lock
  - bundled_plugins_reconcile_failed
  - missing-helper-path
- Likely cause:
  Bundled plugin cache reconcile failed while Windows had files locked.
- Safe next step:
  Close Chrome and Codex, then consider default bundled cache repair only after backup and user approval.
- Not proven:
  A normal Chrome window opening does not prove the Codex Chrome plugin is healthy.
```

This is better than pasting a full private log because it keeps the evidence and removes noise.

## 5. Safe Log Excerpt

Safe issue comments should include short, sanitized strings.

Good:

```text
plugin_cache_windows_file_lock
bundled_plugins_reconcile_failed
os error 5
missing-helper-path
Windows Computer Use helper paths are unavailable
```

Good with a sanitized path:

```text
failed to access:
%USERPROFILE%\.codex\plugins\cache\openai-bundled\<plugin>\<version>\<file>
```

Do not paste:

```text
C:\Users\<real-name>\Documents\<private-project>\...
full thread titles
full conversation logs
email addresses
tokens or API keys
cookies
complete diagnostic logs
```

## 6. What To Attach To An Issue

Use this shape when reporting a problem:

```text
Windows version: Windows 11 <version>
Codex Desktop version: <version if visible>
Affected surface: Chrome / Computer Use / both
Started after: update / restart / plugin change / unknown
Short error strings:
- <short sanitized error string>
Validation:
- Chrome plugin surface: failed / not checked / works
- Computer Use surface: failed / not checked / works
Private details removed: yes
```

If a screenshot is necessary, crop it first and remove:

- Email addresses.
- Private project names.
- Full personal file paths.
- Thread content.
- Tokens, keys, or account identifiers.

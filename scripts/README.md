# Scripts

Scripts in this directory must stay narrow, diagnostic, and safe by default.

## codex-desktop-health-report.ps1

Generates a read-only JSON health report for Windows Codex Desktop plugin diagnosis.

Run:

```powershell
.\scripts\codex-desktop-health-report.ps1
```

Save to a file if needed:

```powershell
.\scripts\codex-desktop-health-report.ps1 > codex-desktop-health-report.json
```

Rules:

- Do not repair anything.
- Do not delete or rebuild `.codex`.
- Do not include full logs or thread session contents.
- Do not collect secrets, cookies, browser profile data, or user prompts.
- Keep output suitable for sanitized GitHub issue reports.

Useful fields:

- `codexConfig`: selected non-secret `config.toml` marketplace and bundled plugin enabled-state evidence.
- `logs.reconcileAssessment.status`: tells whether recent bundled plugin reconcile failures were followed by later success.
- `logs.reconcileAssessment.fileLockEvidence`: flags evidence such as `plugin_cache_windows_file_lock` or `os error 5`.
- `logs.reconcileTimeline`: bounded sanitized timeline of recent bundled plugin reconcile events.

Performance note:

- Pattern counting reads each scanned log file once and checks all known diagnostic strings during that pass.
- The helper scans recent Codex Desktop app logs only; it does not scan Codex thread session files.

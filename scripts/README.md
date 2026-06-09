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

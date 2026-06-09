# Real Issue Playbook

This project should collect real issues, not performative activity.

## What Counts As A Real Issue

A real issue can come from:

- A user whose Codex Desktop Chrome or Computer Use actually failed.
- A maintainer's own machine, if the report is labeled as maintainer-reported.
- A repeatable documentation gap discovered during real troubleshooting.
- A validation failure where the agent could not prove Chrome or Computer Use worked.

The issue does not need to include full private logs. It does need enough sanitized evidence to explain what happened.

## What Does Not Count

- Fake bug reports.
- Copied logs from another machine without permission.
- Issues opened only to make the repository look busy.
- Bought stars or disposable-account stars.
- Claims that a bug is fixed without validation.

## How To Turn A Real Case Into An Issue

1. Record the visible symptom.
2. Record environment basics: Windows version, Codex Desktop version, Chrome version if relevant.
3. Paste only short sanitized log excerpts.
4. Optionally include a summary from `scripts/codex-desktop-health-report.ps1`; do not paste full private logs or thread session content.
5. State what validation failed:
   - Chrome extension backend could not list/use tabs.
   - Computer Use client could not list apps.
   - Current thread did not expose the capability.
6. Add labels such as `windows`, `chrome`, `computer-use`, `plugin-cache`, `capability-loading`, or `needs-evidence`.
7. Close the issue only after a documentation update, diagnosis update, release note, or verified user outcome.

## Good Early Issues

These are legitimate if backed by real evidence:

- Chrome works as a browser but Codex Chrome control fails after update.
- Computer Use reports `missing-helper-path`.
- Chrome and Computer Use fail together after a bundled plugin reconcile error.
- Plugin is enabled in settings but the current thread cannot use it.
- The agent can only prove shell automation works, not the official plugin surface.
- A new Codex Desktop version changes helper/cache paths and the docs need updating.

## Maintainer-Reported Issues

If the maintainer reports their own case, use wording like:

```text
This is a maintainer-reported Windows Codex Desktop case from my own machine. Paths and private thread details are sanitized.
```

That is honest. Do not pretend it came from an external user.

## Practical Plan For This Repository

Start with a small number of real issues:

- 1 maintainer-reported case for Chrome/Computer Use failing after update, if sanitized evidence exists.
- 1 documentation issue for improving validation wording.
- 1 issue for collecting Codex Desktop version/path observations from real users.

Then let future user reports drive the next releases.

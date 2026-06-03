# Example: Computer Use Missing Helper Path

## User Symptom

Computer Use is enabled in Codex Desktop, but Windows app control fails. The user may see that Computer Use is unavailable, or `@Computer` does not actually control Windows apps.

## Evidence To Look For

Recent Codex logs may contain:

```text
computer-use notify config ensure finished
reason=missing-helper-path
status=skipped

computer-use native pipe startup failed
Windows Computer Use helper paths are unavailable
```

The configured helper executable path may point to a missing file under:

```text
%USERPROFILE%\.codex\plugins\cache\openai-bundled\computer-use\...
```

## Plain-Language Cause

Computer Use relies on a helper executable and native pipe setup. If the bundled plugin cache is incomplete after an update or failed reconcile, Codex may not be able to find that helper path. This can happen even if the visible first failure was Chrome, because Chrome and Computer Use both live under the bundled plugin cache system.

## Safe Agent Response

The agent should:

1. Check whether the helper path exists.
2. Check whether the Computer Use plugin cache version directory exists.
3. Use the official Computer Use client flow to try listing apps.
4. If `list_apps` works, Computer Use is functionally available.
5. If helper path is missing and logs support cache damage, propose a default-path cache rebuild with backup and user approval.
6. Validate with the official Computer Use client after repair.

## What Not To Do

- Do not use PowerShell, SendKeys, or shell app launching as proof that Computer Use is fixed.
- Do not directly spawn helper executables or invent a custom protocol.
- Do not repair Photoshop, Drive, GitHub, or Gmail under this skill's scope.

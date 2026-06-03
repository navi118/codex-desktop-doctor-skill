# Safe Repair Boundaries

This skill must protect the user's machine. It should help agents avoid turning a plugin problem into data loss or configuration drift.

## Allowed Without Changing Files

- Read Codex config.
- Read recent Codex logs.
- Check whether expected plugin directories exist.
- Check Chrome running state.
- Check Chrome extension and native host status.
- Check whether the current thread exposes Chrome or Computer Use capability.
- Use official Chrome and Computer Use plugin client flows for lightweight validation.

## Allowed With Explicit User Approval

- Close Chrome and Codex before repair.
- Back up affected Codex plugin cache directories.
- Rebuild only official bundled plugin cache or marketplace mirror from the installed Codex official source.
- Remove a known-bad temporary repair backup after the user confirms it is no longer needed.
- Update a stale Codex config entry only when the desired value is the official default path for that user's current install.

## Forbidden

- Do not delete `%USERPROFILE%\.codex` wholesale.
- Do not delete unrelated skills, memories, automations, projects, or connector settings.
- Do not install global packages or services.
- Do not create startup tasks.
- Do not hardcode another user's versioned paths.
- Do not replace official Codex plugin files with downloaded third-party files.
- Do not edit Chrome profile internals unless the user explicitly asks and the risk is explained.
- Do not treat shell automation as proof that Computer Use works.
- Do not treat normal Chrome browsing as proof that the Codex Chrome plugin works.

## Repair Preconditions

Only propose a cache rebuild when all of these are true:

1. The machine is Windows.
2. The affected plugin is Chrome or Computer Use.
3. Evidence points to bundled plugin cache or marketplace state.
4. Official installed Codex bundled source can be found.
5. The target cache path is the user's own default Codex cache path.
6. The user has approved the file-changing repair.
7. Chrome and Codex can be closed, or the repair can be delayed until they are closed.
8. A backup destination is selected before replacement.

If any precondition fails, stop at diagnosis and report what is missing.

## Repair Explanation Template

Use this plain-language explanation before repair:

```text
I found evidence that Codex's bundled plugin cache is incomplete or locked during update.
The repair I propose does not change custom runtime behavior.
It backs up the affected default cache, then rebuilds Chrome/Computer Use plugin files from the installed official Codex package into Codex's default user cache.
If the installed source cannot be found or the paths are not default, I will stop instead of forcing it.
```

## Post-Repair Checks

After repair:

- Verify relevant directories exist.
- Verify config points to existing official default paths.
- Verify Chrome extension backend can be used if Chrome was affected.
- Verify Computer Use can list apps if Computer Use was affected.
- Tell the user whether the repair fully passed, partially passed, or failed.

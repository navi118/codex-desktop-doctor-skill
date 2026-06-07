# Example: Current Thread Capability Not Loaded

## User Symptom

The plugin appears enabled in Codex Desktop settings, but the current thread cannot use the capability. The user may see a tool-not-found style failure or the agent may report that the backend is unavailable.

## Evidence To Look For

Signals may include:

```text
tool not found
backend not available in this thread
config enabled but no callable tool/backend appears
```

Local checks may show:

- Plugin cache files exist.
- Plugin appears enabled in settings.
- A fresh thread or restart may expose the capability.

## Plain-Language Cause

Codex settings and local plugin files are not the same thing as the current thread having the tool loaded. A thread can be started before a plugin becomes available, or plugin capability discovery may need a refresh.

## Safe Agent Response

The agent should:

1. Explain that plugin enabled state is not proof that the current thread can use it.
2. Try tool discovery or a fresh thread before changing files.
3. Restart Codex if fresh threads still do not load the capability.
4. Only investigate cache damage if logs or missing paths also support it.

## What Not To Do

- Do not rebuild plugin cache only because a single old thread lacks a backend.
- Do not call normal shell/browser automation a plugin validation.
- Do not say the issue is fixed unless the intended thread or a fresh thread can use the real capability.

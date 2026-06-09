# Supported Failures

This document defines the project's supported diagnosis scope.

## Supported Now

### Chrome Plugin Control Failure

Symptoms:

- `@Chrome` is installed or enabled but cannot control Chrome.
- Chrome opens normally, but Codex cannot communicate with the extension.
- Native host manifest or extension backend appears broken.

Validation:

- The actual Codex Chrome extension backend can list or use tabs.

### Computer Use Failure

Symptoms:

- Computer Use is enabled but cannot control Windows apps.
- Logs mention `missing-helper-path`.
- Native pipe startup fails.

Validation:

- The official Computer Use client can list apps or inspect a window.

### Bundled Plugin Cache Or Marketplace Failure

Symptoms:

- Logs mention `bundled_plugins_reconcile_failed`.
- Logs mention `plugin_cache_windows_file_lock`.
- Paths under `.codex\plugins\cache\openai-bundled` are missing or partial.
- Recent logs need classification as transient recovery or possible persistent damage.

Validation:

- Recent logs show whether `bundled_plugins_reconcile_completed` appeared after the failure.
- The affected official plugin surface works after refresh or repair.

### Current-Thread Capability Loading Failure

Symptoms:

- Plugin appears enabled in settings.
- Local plugin files look present.
- The current thread still has no callable backend/tool.

Validation:

- A new thread, app restart, or tool discovery exposes the expected capability.

## Not Supported Yet

- General connector failures for GitHub, Gmail, Drive, Photoshop, Cloudflare, Slack, or similar.
- General account, billing, model, or subscription support.
- Arbitrary MCP server setup.
- Non-Windows desktop diagnosis.
- Browser automation that does not involve the Codex Chrome plugin.

Unsupported cases may become supported later only after repeated real reports and a reliable validation method.

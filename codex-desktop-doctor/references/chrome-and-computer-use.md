# Chrome And Computer Use Diagnosis

This reference is for Windows Codex Desktop only.

## What To Check First

Start with evidence that does not modify the system:

1. Codex config and plugin state
   - `%USERPROFILE%\.codex\config.toml`
   - `%USERPROFILE%\.codex\plugins\cache\openai-bundled`
   - `%USERPROFILE%\.codex\.tmp\bundled-marketplaces\openai-bundled`
   - Enabled plugin entries for `chrome@openai-bundled` and `computer-use@openai-bundled`

2. Current thread capability
   - Do not rely only on config.
   - Confirm the current Codex thread can actually load the Chrome skill/backend or Computer Use runtime.
   - For Chrome, the backend may identify itself as `extension`, not literally `chrome`.

3. Chrome-specific checks
   - Chrome is installed.
   - Chrome is running when extension communication is expected.
   - Codex Chrome Extension is installed and enabled in the selected Chrome profile.
   - Native Messaging Host manifest exists and points to the expected host.
   - Registry key under `HKCU\Software\Google\Chrome\NativeMessagingHosts\...` matches the manifest path.
   - Prefer structured PowerShell registry reads over parsing localized `reg.exe` output.
   - Check whether the manifest host path points into mutable Codex cache locations such as `.codex\plugins\cache\openai-bundled\chrome\latest`.
   - Remember that a running `extension-host.exe` is not enough; the Chrome extension backend still has to be exposed to Codex.

4. Computer Use-specific checks
   - The Computer Use plugin cache directory exists.
   - The official `scripts\computer-use-client.mjs` entry point exists in the plugin folder.
   - Logs do not show `missing-helper-path`.
   - The official Computer Use client can list apps.

## Why Chrome Can Break After Updates

Chrome plugin failures often involve three moving pieces:

1. Chrome extension
   - Lives in the Chrome profile.
   - Talks to Codex through the native messaging host.

2. Native messaging host
   - Registered through a JSON manifest and Windows registry.
   - May launch a helper process that stays alive while Chrome is running.

3. Codex bundled plugin cache
   - Lives under `.codex\plugins\cache\openai-bundled`.
   - Can be reconciled during Codex startup or update.

On Windows, running executables cannot always be moved, replaced, or deleted. If Codex tries to reconcile a mutable plugin cache while Chrome or a native host still has a handle open, Windows can return access denied. The result can be a partial update: some plugin files are new, some are old, and some expected helper paths are missing.

If a later `bundled_plugins_reconcile_completed` event appears after the failure, the cache may have recovered. Treat that as a separate state from persistent damage. Still validate the real Chrome backend or Computer Use helper before calling the issue fixed.

## Why Computer Use Can Break At The Same Time

Computer Use depends on bundled plugin files, its official client script, and native pipe metadata. If bundled plugin reconciliation fails on Chrome first, the broader bundled plugin marketplace or cache can be left inconsistent. Computer Use may then fail even though the visible error mentions only its own helper or native pipe.

Common chain:

1. Chrome or extension host keeps a bundled plugin cache file locked.
2. Codex update/startup reconcile fails while backing up or replacing cache entries.
3. Bundled plugin state becomes partial.
4. Computer Use cannot load its client path, receive native pipe metadata, or start its native pipe.

This is why Chrome and Computer Use can fail together after an update.

## Safe Diagnosis Commands And Methods

Prefer official plugin health checks where available. Use the plugin's own instructions and bundled client scripts instead of writing a custom protocol client.

For Chrome:
- Use the Chrome skill's browser-client flow first.
- If it fails, use the Chrome plugin's own check scripts for:
  - Chrome installed
  - Chrome running
  - extension installed/enabled
  - native host manifest correct

For Computer Use:
- Use the Computer Use skill's official client flow.
- A successful `list_apps` style call is enough to prove the helper is reachable.

Avoid:
- Opening Chrome through shell and calling it a Chrome plugin repair.
- Launching Windows apps through shell and calling it a Computer Use repair.
- Importing internal helper packages directly or spawning helper executables when the skill provides an official client.

## Validation

Call the repair complete only when both relevant conditions pass:

- Chrome issue: actual Chrome extension backend is usable, not merely that Chrome.exe runs.
- Computer Use issue: official Computer Use client can list apps or inspect a window.

If local files look correct but the thread cannot use the backend, classify it as a current-thread capability loading problem. Suggest a new thread or Codex restart rather than editing files.

If the Native Messaging registry entry, manifest, and `extension-host.exe` process all exist but the browser runtime still reports only the in-app browser backend, classify it as a Chrome backend exposure problem. Do not downgrade it to a simple install problem.

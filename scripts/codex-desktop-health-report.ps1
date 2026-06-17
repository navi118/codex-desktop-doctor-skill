param(
    [int]$LogDays = 7,
    [int]$MaxLogFiles = 40
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function ConvertTo-SafePath {
    param([AllowNull()][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $Path
    }

    $userHome = [Environment]::GetFolderPath("UserProfile")
    $comparisonPath = $Path
    $displayPrefix = ""

    if ($comparisonPath.StartsWith("\\?\", [StringComparison]::OrdinalIgnoreCase)) {
        $comparisonPath = $comparisonPath.Substring(4)
        $displayPrefix = "\\?\"
    }

    if (-not [string]::IsNullOrWhiteSpace($userHome) -and $comparisonPath.StartsWith($userHome, [StringComparison]::OrdinalIgnoreCase)) {
        return $displayPrefix + "%USERPROFILE%" + $comparisonPath.Substring($userHome.Length)
    }

    return $Path
}

function Resolve-EnvironmentPath {
    param([AllowNull()][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $Path
    }

    return [Environment]::ExpandEnvironmentVariables($Path)
}

function Get-ObjectPropertyValue {
    param(
        [AllowNull()][object]$Object,
        [string]$Name
    )

    if ($null -eq $Object) {
        return $null
    }

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Get-DirectoryNames {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return @()
    }

    return @(Get-ChildItem -LiteralPath $Path -Directory -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object { $_.Name })
}

function Get-FileExists {
    param([string]$Path)

    return [bool](Test-Path -LiteralPath $Path -PathType Leaf)
}

function Get-DirectoryExists {
    param([string]$Path)

    return [bool](Test-Path -LiteralPath $Path -PathType Container)
}

function Get-AppxPackageSafe {
    $packages = @()

    if (-not (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue)) {
        return @{
            available = $false
            packages = @()
        }
    }

    try {
        $packages = @(Get-AppxPackage -Name "OpenAI.Codex" -ErrorAction SilentlyContinue | ForEach-Object {
            @{
                name = $_.Name
                version = $_.Version.ToString()
                packageFullName = $_.PackageFullName
                installLocation = ConvertTo-SafePath $_.InstallLocation
            }
        })
    }
    catch {
        return @{
            available = $true
            error = $_.Exception.Message
            packages = @()
        }
    }

    return @{
        available = $true
        packages = $packages
    }
}

function Get-WindowsInfoSafe {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        return @{
            caption = $os.Caption
            version = $os.Version
            buildNumber = $os.BuildNumber
            architecture = $os.OSArchitecture
        }
    }
    catch {
        return @{
            error = $_.Exception.Message
        }
    }
}

function Get-ProcessCounts {
    $names = @(
        "Codex",
        "chrome",
        "extension-host",
        "codex-computer-use"
    )

    $result = @{}
    foreach ($name in $names) {
        $result[$name] = @(
            Get-Process -Name $name -ErrorAction SilentlyContinue
        ).Count
    }

    return $result
}

function Get-ExtensionHostProcesses {
    $processes = @()

    foreach ($process in @(Get-Process -Name "extension-host" -ErrorAction SilentlyContinue)) {
        $path = $null
        try {
            $path = $process.Path
        }
        catch {
            $path = $null
        }

        $processes += @{
            id = $process.Id
            path = ConvertTo-SafePath $path
        }
    }

    return $processes
}

function Test-CodexMutablePluginPath {
    param([AllowNull()][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    $normalized = $Path.Replace("/", "\")
    $indicators = @(
        "\.codex\plugins\cache\openai-bundled\chrome\latest\",
        "\.codex\.tmp\bundled-marketplaces\openai-bundled\",
        "\.codex\.tmp\bundled-marketplaces\openai-bundled\plugins\chrome\"
    )

    foreach ($indicator in $indicators) {
        if ($normalized.IndexOf($indicator, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            return $true
        }
    }

    return $false
}

function Get-ChromeNativeMessagingReport {
    $hostName = "com.openai.codexextension"
    $registryPath = "HKCU:\Software\Google\Chrome\NativeMessagingHosts\$hostName"
    $registryDefaultRaw = $null
    $registryError = $null
    $registryExists = Test-Path -LiteralPath $registryPath

    if ($registryExists) {
        try {
            $registryDefaultRaw = (Get-Item -LiteralPath $registryPath -ErrorAction Stop).GetValue("")
        }
        catch {
            $registryError = $_.Exception.Message
        }
    }

    $manifestPathExpanded = Resolve-EnvironmentPath $registryDefaultRaw
    $manifestExists = $false
    $manifestParseError = $null
    $manifestName = $null
    $manifestHostPathRaw = $null
    $manifestAllowedOrigins = @()

    if (-not [string]::IsNullOrWhiteSpace($manifestPathExpanded)) {
        $manifestExists = Get-FileExists $manifestPathExpanded

        if ($manifestExists) {
            try {
                $manifestJson = Get-Content -LiteralPath $manifestPathExpanded -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
                $manifestName = Get-ObjectPropertyValue -Object $manifestJson -Name "name"
                $manifestHostPathRaw = Get-ObjectPropertyValue -Object $manifestJson -Name "path"
                $origins = Get-ObjectPropertyValue -Object $manifestJson -Name "allowed_origins"
                if ($null -ne $origins) {
                    $manifestAllowedOrigins = @($origins)
                }
            }
            catch {
                $manifestParseError = $_.Exception.Message
            }
        }
    }

    $manifestHostPathExpanded = Resolve-EnvironmentPath $manifestHostPathRaw
    $manifestHostPathExists = $false
    if (-not [string]::IsNullOrWhiteSpace($manifestHostPathExpanded)) {
        $manifestHostPathExists = Get-FileExists $manifestHostPathExpanded
    }

    return @{
        hostName = $hostName
        registry = @{
            keyPath = $registryPath
            exists = $registryExists
            defaultValuePresent = -not [string]::IsNullOrWhiteSpace($registryDefaultRaw)
            manifestPath = ConvertTo-SafePath $manifestPathExpanded
            error = $registryError
        }
        manifest = @{
            exists = $manifestExists
            parseError = $manifestParseError
            name = $manifestName
            allowedOrigins = $manifestAllowedOrigins
            hostPath = ConvertTo-SafePath $manifestHostPathExpanded
            hostPathExists = $manifestHostPathExists
            hostPathLooksMutableCache = Test-CodexMutablePluginPath $manifestHostPathExpanded
        }
        runningExtensionHosts = Get-ExtensionHostProcesses
        diagnosticNotes = @(
            "Registry default value is read through PowerShell registry APIs, not localized reg.exe text output.",
            "A present registry key, valid manifest, and running extension-host process do not prove the Chrome extension backend is exposed to Codex.",
            "If hostPathLooksMutableCache is true, Chrome may lock a path Codex later tries to reconcile."
        )
    }
}

function Get-RecentLogFiles {
    param(
        [string[]]$Roots,
        [int]$Days,
        [int]$Limit
    )

    $cutoff = (Get-Date).AddDays(-1 * [Math]::Abs($Days))
    $files = @()

    foreach ($root in $Roots) {
        if (-not (Test-Path -LiteralPath $root -PathType Container)) {
            continue
        }

        $files += @(Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object {
                $_.LastWriteTime -ge $cutoff -and
                ($_.Extension -eq ".log" -or $_.Extension -eq ".txt")
            })
    }

    return @($files | Sort-Object LastWriteTime -Descending | Select-Object -First $Limit)
}

function Get-LogPatternSummary {
    param(
        [object[]]$Files,
        [string[]]$Patterns
    )

    $summary = @()

    foreach ($pattern in $Patterns) {
        $count = 0
        $latest = $null

        foreach ($file in $Files) {
            try {
                $matches = @(Select-String -LiteralPath $file.FullName -Pattern $pattern -SimpleMatch -ErrorAction SilentlyContinue)
            }
            catch {
                $matches = @()
            }

            if ($matches.Count -gt 0) {
                $count += $matches.Count
                if ($null -eq $latest -or $file.LastWriteTime -gt $latest.fileLastWriteTime) {
                    $latest = @{
                        fileName = $file.Name
                        fileLastWriteTime = $file.LastWriteTime.ToString("o")
                        lineNumber = $matches[-1].LineNumber
                    }
                }
            }
        }

        $summary += @{
            pattern = $pattern
            count = $count
            latest = $latest
        }
    }

    return $summary
}

function Get-FieldValue {
    param(
        [string]$Text,
        [string]$Field
    )

    $match = [regex]::Match($Text, "(?:^|\s)$([regex]::Escape($Field))=(?<value>[^\s]+)")
    if ($match.Success) {
        return $match.Groups["value"].Value.Trim('"')
    }

    return $null
}

function Get-ReconcileEvents {
    param([object[]]$Files)

    $events = @()
    $eventPatterns = @(
        "bundled_plugins_reconcile_started",
        "bundled_plugins_reconcile_completed",
        "bundled_plugins_reconcile_failed",
        "bundled_plugins_marketplace_install_failed",
        "bundled_plugin_reinstall_uninstall_requested",
        "bundled_plugin_install_requested"
    )

    foreach ($file in $Files) {
        $lineNumber = 0

        try {
            foreach ($line in Get-Content -LiteralPath $file.FullName -ErrorAction Stop) {
                $lineNumber += 1

                $matchesEvent = $false
                foreach ($pattern in $eventPatterns) {
                    if ($line.Contains($pattern)) {
                        $matchesEvent = $true
                        break
                    }
                }

                if (-not $matchesEvent) {
                    continue
                }

                $timestampMatch = [regex]::Match($line, "^(?<timestamp>\d{4}-\d{2}-\d{2}T[^\s]+)")
                if (-not $timestampMatch.Success) {
                    continue
                }

                $timestamp = [datetime]::MinValue
                if (-not [datetime]::TryParse($timestampMatch.Groups["timestamp"].Value, [ref]$timestamp)) {
                    continue
                }

                $kind = "other"
                if ($line.Contains("bundled_plugins_reconcile_started")) {
                    $kind = "reconcile_started"
                }
                elseif ($line.Contains("bundled_plugins_reconcile_completed")) {
                    $kind = "reconcile_completed"
                }
                elseif ($line.Contains("bundled_plugins_reconcile_failed")) {
                    $kind = "reconcile_failed"
                }
                elseif ($line.Contains("bundled_plugins_marketplace_install_failed")) {
                    $kind = "marketplace_install_failed"
                }
                elseif ($line.Contains("bundled_plugin_reinstall_uninstall_requested")) {
                    $kind = "plugin_reinstall_uninstall_requested"
                }
                elseif ($line.Contains("bundled_plugin_install_requested")) {
                    $kind = "plugin_install_requested"
                }

                $fileLockEvidence = (
                    $line.Contains("plugin_cache_windows_file_lock") -or
                    $line.Contains("os error 5") -or
                    $line.Contains("Access is denied") -or
                    $line.Contains("failed to remove existing plugin cache entry") -or
                    $line.Contains("failed to back up plugin cache entry")
                )

                $events += [pscustomobject]@{
                    timestamp = $timestamp
                    kind = $kind
                    pluginName = Get-FieldValue -Text $line -Field "pluginName"
                    reason = Get-FieldValue -Text $line -Field "reason"
                    installReason = Get-FieldValue -Text $line -Field "installReason"
                    installPhase = Get-FieldValue -Text $line -Field "installPhase"
                    errorCategory = Get-FieldValue -Text $line -Field "errorCategory"
                    fileLockEvidence = $fileLockEvidence
                    fileName = $file.Name
                    lineNumber = $lineNumber
                }
            }
        }
        catch {
            continue
        }
    }

    return @($events | Sort-Object timestamp)
}

function Convert-ReconcileEventForReport {
    param([object]$Event)

    return @{
        timestamp = $Event.timestamp.ToString("o")
        kind = $Event.kind
        pluginName = $Event.pluginName
        reason = $Event.reason
        installReason = $Event.installReason
        installPhase = $Event.installPhase
        errorCategory = $Event.errorCategory
        fileLockEvidence = $Event.fileLockEvidence
        fileName = $Event.fileName
        lineNumber = $Event.lineNumber
    }
}

function Get-ReconcileAssessment {
    param([object[]]$Events)

    $safeEvents = @($Events | Where-Object {
        $null -ne $_ -and
        $_.PSObject.Properties.Name -contains "kind" -and
        $_.PSObject.Properties.Name -contains "timestamp"
    })

    $failures = @($safeEvents | Where-Object {
        $_.kind -eq "reconcile_failed" -or $_.kind -eq "marketplace_install_failed"
    } | Sort-Object timestamp)

    if ($failures.Count -eq 0) {
        return @{
            status = "no-recent-reconcile-failure"
            latestFailure = $null
            latestSuccessAfterFailure = $null
            fileLockEvidence = $false
            affectedPlugins = @()
            explanation = "No recent bundled plugin reconcile failure was found in the scanned logs."
        }
    }

    $latestFailure = $failures[-1]
    $successAfterFailure = @($safeEvents | Where-Object {
        $_.kind -eq "reconcile_completed" -and $_.timestamp -gt $latestFailure.timestamp
    } | Sort-Object timestamp | Select-Object -First 1)

    $fileLockEvidence = [bool](@($failures | Where-Object { $_.fileLockEvidence }).Count -gt 0)
    $affectedPlugins = @($failures |
        ForEach-Object { $_.pluginName } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Sort-Object -Unique)

    if ($successAfterFailure.Count -gt 0) {
        $success = $successAfterFailure[0]
        return @{
            status = "transient-failure-followed-by-success"
            latestFailure = Convert-ReconcileEventForReport $latestFailure
            latestSuccessAfterFailure = Convert-ReconcileEventForReport $success
            fileLockEvidence = $fileLockEvidence
            affectedPlugins = $affectedPlugins
            explanation = "A bundled plugin reconcile failure was followed by a later successful reconcile in the scanned logs. This suggests recovery happened, but the functional Chrome or Computer Use surface should still be validated."
        }
    }

    return @{
        status = "failure-without-later-success"
        latestFailure = Convert-ReconcileEventForReport $latestFailure
        latestSuccessAfterFailure = $null
        fileLockEvidence = $fileLockEvidence
        affectedPlugins = $affectedPlugins
        explanation = "A bundled plugin reconcile failure was found without a later successful reconcile in the scanned logs. This may indicate persistent plugin cache damage until functional validation proves otherwise."
    }
}

function Get-PluginVersionReport {
    param(
        [string]$CacheRoot,
        [string]$PluginName,
        [AllowEmptyString()][string]$ExpectedRelativeFile
    )

    $pluginRoot = Join-Path $CacheRoot $PluginName
    $versions = Get-DirectoryNames $pluginRoot
    $expectedFiles = @()
    $expectedFileExistsAny = $null

    if (-not [string]::IsNullOrWhiteSpace($ExpectedRelativeFile)) {
        foreach ($version in $versions) {
            $candidate = Join-Path (Join-Path $pluginRoot $version) $ExpectedRelativeFile
            $expectedFiles += @{
                version = $version
                path = ConvertTo-SafePath $candidate
                exists = Get-FileExists $candidate
            }
        }

        $expectedFileExistsAny = [bool](@($expectedFiles | Where-Object { $_.exists }).Count -gt 0)
    }

    return @{
        versions = $versions
        expectedFileExistsAny = $expectedFileExistsAny
        expectedFiles = $expectedFiles
    }
}

function ConvertFrom-SimpleTomlValue {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return $null
    }

    $trimmed = $Value.Trim()

    if ($trimmed.StartsWith('"') -and $trimmed.EndsWith('"')) {
        if ($trimmed.Length -lt 2) {
            return ""
        }
        return $trimmed.Substring(1, $trimmed.Length - 2)
    }

    if ($trimmed.StartsWith("'") -and $trimmed.EndsWith("'")) {
        if ($trimmed.Length -lt 2) {
            return ""
        }
        return $trimmed.Substring(1, $trimmed.Length - 2)
    }

    if ($trimmed -ieq "true") {
        return $true
    }

    if ($trimmed -ieq "false") {
        return $false
    }

    return $trimmed
}

function Get-CodexConfigReport {
    param([string]$CodexHome)

    $configPath = Join-Path $CodexHome "config.toml"
    $exists = Get-FileExists $configPath
    $targetPlugins = @(
        "browser@openai-bundled",
        "chrome@openai-bundled",
        "computer-use@openai-bundled"
    )
    $pluginSections = [ordered]@{}

    foreach ($plugin in $targetPlugins) {
        $pluginSections[$plugin] = @{
            sectionPresent = $false
            enabled = $null
        }
    }

    $report = [ordered]@{
        path = ConvertTo-SafePath $configPath
        exists = $exists
        runCodexInWindowsSubsystemForLinux = $null
        openaiBundledMarketplace = @{
            sectionPresent = $false
            source = $null
            sourceExists = $null
            sourceLooksDefaultTmp = $null
            sourceLooksStableUserCopy = $null
        }
        bundledPluginConfig = $pluginSections
        diagnosticNotes = @(
            "Only selected non-secret config keys are reported.",
            "A plugin can be enabled in config.toml while the active Codex thread still lacks the callable backend.",
            "Marketplace source presence does not prove the plugin cache is complete."
        )
    }

    if (-not $exists) {
        return $report
    }

    $currentSection = ""
    foreach ($line in @(Get-Content -LiteralPath $configPath -ErrorAction SilentlyContinue)) {
        if ($line -match '^\s*\[(.+)\]\s*$') {
            $currentSection = $Matches[1]

            foreach ($plugin in $targetPlugins) {
                if ($currentSection -eq "plugins.`"$plugin`"") {
                    $report.bundledPluginConfig[$plugin].sectionPresent = $true
                }
            }

            if ($currentSection -eq "marketplaces.openai-bundled") {
                $report.openaiBundledMarketplace.sectionPresent = $true
            }

            continue
        }

        if ($line -notmatch '^\s*([A-Za-z0-9_\-]+)\s*=\s*(.+?)\s*(?:#.*)?$') {
            continue
        }

        $key = $Matches[1]
        $value = ConvertFrom-SimpleTomlValue $Matches[2]

        if ($currentSection -eq "" -and $key -eq "runCodexInWindowsSubsystemForLinux") {
            $report.runCodexInWindowsSubsystemForLinux = $value
            continue
        }

        if ($currentSection -eq "marketplaces.openai-bundled" -and $key -eq "source") {
            $sourcePath = Resolve-EnvironmentPath $value
            $normalized = $sourcePath.Replace("/", "\")
            $report.openaiBundledMarketplace.source = ConvertTo-SafePath $sourcePath
            $report.openaiBundledMarketplace.sourceExists = Get-DirectoryExists $sourcePath
            $report.openaiBundledMarketplace.sourceLooksDefaultTmp = $normalized.IndexOf("\.codex\.tmp\bundled-marketplaces\openai-bundled", [StringComparison]::OrdinalIgnoreCase) -ge 0
            $report.openaiBundledMarketplace.sourceLooksStableUserCopy = $normalized.IndexOf("\.codex\bundled-marketplaces\openai-bundled", [StringComparison]::OrdinalIgnoreCase) -ge 0
            continue
        }

        foreach ($plugin in $targetPlugins) {
            if ($currentSection -eq "plugins.`"$plugin`"" -and $key -eq "enabled") {
                $report.bundledPluginConfig[$plugin].enabled = $value
            }
        }
    }

    return $report
}

$codexHome = Join-Path $env:USERPROFILE ".codex"
$pluginCacheRoot = Join-Path $codexHome "plugins\cache\openai-bundled"
$marketplaceRoot = Join-Path $codexHome ".tmp\bundled-marketplaces\openai-bundled"
$appPackageRoot = Join-Path $env:LOCALAPPDATA "Packages"
$codexPackageRoots = @()

if (Test-Path -LiteralPath $appPackageRoot -PathType Container) {
    $codexPackageRoots = @(Get-ChildItem -LiteralPath $appPackageRoot -Directory -Filter "OpenAI.Codex_*" -ErrorAction SilentlyContinue)
}

$logRoots = @()
foreach ($packageRoot in $codexPackageRoots) {
    $logRoot = Join-Path $packageRoot.FullName "LocalCache\Local\Codex\Logs"
    if (Test-Path -LiteralPath $logRoot -PathType Container) {
        $logRoots += $logRoot
    }
}

$patterns = @(
    "bundled_plugins_marketplace_install_failed",
    "bundled_plugins_reconcile_failed",
    "plugin_cache_windows_file_lock",
    "failed to remove existing plugin cache entry",
    "failed to back up plugin cache entry",
    "os error 5",
    "Access is denied",
    "refused access",
    "missing-helper-path",
    "Windows Computer Use helper paths are unavailable",
    "computer-use native pipe startup failed",
    "Cannot communicate with the Codex Chrome Extension",
    "Browser is not available: extension",
    "Browser is not available: chrome",
    "native host manifest missing",
    "native host manifest invalid"
)

$recentLogFiles = Get-RecentLogFiles -Roots $logRoots -Days $LogDays -Limit $MaxLogFiles
$reconcileEvents = Get-ReconcileEvents -Files $recentLogFiles

$report = [ordered]@{
    schemaVersion = 3
    generatedAt = (Get-Date).ToString("o")
    safety = @{
        readOnly = $true
        repairsAttempted = $false
        fullLogLinesIncluded = $false
        pathSanitization = "User profile paths are replaced with %USERPROFILE%."
    }
    environment = @{
        windows = Get-WindowsInfoSafe
        codexAppx = Get-AppxPackageSafe
    }
    codexConfig = Get-CodexConfigReport $codexHome
    paths = @{
        codexHome = @{
            path = ConvertTo-SafePath $codexHome
            exists = Get-DirectoryExists $codexHome
        }
        pluginCacheRoot = @{
            path = ConvertTo-SafePath $pluginCacheRoot
            exists = Get-DirectoryExists $pluginCacheRoot
            pluginNames = Get-DirectoryNames $pluginCacheRoot
        }
        bundledMarketplaceRoot = @{
            path = ConvertTo-SafePath $marketplaceRoot
            exists = Get-DirectoryExists $marketplaceRoot
            pluginNames = Get-DirectoryNames (Join-Path $marketplaceRoot "plugins")
            marketplaceJsonExists = Get-FileExists (Join-Path $marketplaceRoot ".agents\plugins\marketplace.json")
        }
    }
    bundledPlugins = @{
        browser = Get-PluginVersionReport -CacheRoot $pluginCacheRoot -PluginName "browser" -ExpectedRelativeFile ""
        chrome = Get-PluginVersionReport -CacheRoot $pluginCacheRoot -PluginName "chrome" -ExpectedRelativeFile "extension-host\windows\x64\extension-host.exe"
        computerUse = Get-PluginVersionReport -CacheRoot $pluginCacheRoot -PluginName "computer-use" -ExpectedRelativeFile "node_modules\@oai\sky\bin\windows\codex-computer-use.exe"
    }
    chromeNativeMessaging = Get-ChromeNativeMessagingReport
    processCounts = Get-ProcessCounts
    logs = @{
        roots = @($logRoots | ForEach-Object { ConvertTo-SafePath $_ })
        scannedFileCount = $recentLogFiles.Count
        scannedSinceDays = $LogDays
        patternSummary = Get-LogPatternSummary -Files $recentLogFiles -Patterns $patterns
        reconcileTimeline = @($reconcileEvents | Select-Object -Last 30 | ForEach-Object { Convert-ReconcileEventForReport $_ })
        reconcileAssessment = Get-ReconcileAssessment -Events $reconcileEvents
    }
    interpretationHints = @(
        "If plugin_cache_windows_file_lock, os error 5, or failed to remove existing plugin cache entry appears near a Codex update, Chrome or the extension host may have locked files Codex tried to replace.",
        "If reconcileAssessment.status is transient-failure-followed-by-success, the cache may have recovered, but functional validation is still required.",
        "If reconcileAssessment.status is failure-without-later-success, treat the cache as possibly damaged until Chrome or Computer Use validation proves otherwise.",
        "If expectedFileExistsAny is false for Computer Use, the bundled plugin cache may be incomplete.",
        "If bundledPluginConfig shows a plugin enabled but no callable backend appears, treat it as a runtime exposure problem, not proof that the plugin works.",
        "If Chrome native messaging registry and manifest exist but Browser is not available: extension appears, treat it as a backend exposure problem rather than a simple install problem.",
        "If files exist but the plugin still fails, validate the real Chrome extension backend or Computer Use helper before claiming repair."
    )
}

$report | ConvertTo-Json -Depth 8

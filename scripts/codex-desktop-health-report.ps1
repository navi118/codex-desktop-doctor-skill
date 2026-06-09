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
    if (-not [string]::IsNullOrWhiteSpace($userHome) -and $Path.StartsWith($userHome, [StringComparison]::OrdinalIgnoreCase)) {
        return "%USERPROFILE%" + $Path.Substring($userHome.Length)
    }

    return $Path
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
    "native host manifest missing",
    "native host manifest invalid"
)

$recentLogFiles = Get-RecentLogFiles -Roots $logRoots -Days $LogDays -Limit $MaxLogFiles

$report = [ordered]@{
    schemaVersion = 1
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
    processCounts = Get-ProcessCounts
    logs = @{
        roots = @($logRoots | ForEach-Object { ConvertTo-SafePath $_ })
        scannedFileCount = $recentLogFiles.Count
        scannedSinceDays = $LogDays
        patternSummary = Get-LogPatternSummary -Files $recentLogFiles -Patterns $patterns
    }
    interpretationHints = @(
        "If plugin_cache_windows_file_lock, os error 5, or failed to remove existing plugin cache entry appears near a Codex update, Chrome or the extension host may have locked files Codex tried to replace.",
        "If helperExists is false for Computer Use, the bundled plugin cache may be incomplete.",
        "If files exist but the plugin still fails, validate the real Chrome extension backend or Computer Use helper before claiming repair."
    )
}

$report | ConvertTo-Json -Depth 8

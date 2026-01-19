if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -notmatch '^#' -and $_ -match '=') {
            $name, $value = $_ -split '=', 2
            # Strip surrounding quotes from value
            $value = $value -replace '^"|"$', ''
            [System.Environment]::SetEnvironmentVariable($name, $value)
        }
    }
} else {
    Write-Host "Error: .env file not found."
    exit 1
}

$imageName = $args[0]
$dockerFilePath = "./ci/build/Dockerfile"

# Get project directory dynamically from current location
$currentPath = (Get-Location).Path -replace '\\', '/'
$driveLetter = $currentPath.Substring(0, 1).ToUpper()
$pathWithoutDrive = $currentPath.Substring(2)
$projectDir = "/${driveLetter}${pathWithoutDrive}"

# Use WoW addon directories from .env file (loaded above)
$wowAddonsDirTbc = [System.Environment]::GetEnvironmentVariable("wow_addons_dir_tbc")
$wowAddonsDirPtr = [System.Environment]::GetEnvironmentVariable("wow_addons_dir_ptr")
$wowAddonsDirEra = [System.Environment]::GetEnvironmentVariable("wow_addons_dir_era")

if (-not $wowAddonsDirTbc) {
    Write-Host "Warning: wow_addons_dir_tbc not set in .env file"
}
if (-not $wowAddonsDirPtr) {
    Write-Host "Warning: wow_addons_dir_ptr not set in .env file"
}
if (-not $wowAddonsDirEra) {
    Write-Host "Warning: wow_addons_dir_era not set in .env file"
}


Write-Host "Building Docker image: $imageName"
docker build -t $imageName -f $dockerFilePath .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed."
    exit 1
}

Write-Host "Running Docker container and mounting project directory.."
Write-Host "Project dir: ${projectDir}"
Write-Host "WoW Addons dir (TBC): ${wowAddonsDirTbc}"
Write-Host "WoW Addons dir (PTR): ${wowAddonsDirPtr}"
Write-Host "WoW Addons dir (Era): ${wowAddonsDirEra}"

# Helper function to extract drive letter from path (handles quotes and case)
function Get-DriveLetter($path) {
    if ($path -match '^"?/([a-zA-Z])/') {
        return $matches[1].ToUpper()
    }
    return $null
}

# Helper function to clean path (remove surrounding quotes)
function Clean-Path($path) {
    return $path -replace '^"|"$', ''
}

# Extract drive letters from all paths to determine unique drives needed
$drives = @{}
$projectDriveLetter = Get-DriveLetter $projectDir
if ($projectDriveLetter) { $drives[$projectDriveLetter] = $true }

if ($wowAddonsDirTbc) {
    $drive = Get-DriveLetter $wowAddonsDirTbc
    if ($drive) { $drives[$drive] = $true }
}
if ($wowAddonsDirPtr) {
    $drive = Get-DriveLetter $wowAddonsDirPtr
    if ($drive) { $drives[$drive] = $true }
}
if ($wowAddonsDirEra) {
    $drive = Get-DriveLetter $wowAddonsDirEra
    if ($drive) { $drives[$drive] = $true }
}

# Build volume mount arguments - mount each unique drive once
$volumeArgs = @()
foreach ($drive in $drives.Keys) {
    $volumeArgs += @("-v", "/${drive}:/${drive}")
}

# Clean project dir for working directory
$cleanProjectDir = Clean-Path $projectDir

Write-Host "Mounting drives: $($drives.Keys -join ', ')"
Write-Host "Docker command: docker run --rm -ti $($volumeArgs -join ' ') -w ${cleanProjectDir} $imageName bash"

docker run --rm -ti @volumeArgs -w $cleanProjectDir $imageName bash

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to start Docker container."
    exit 1
}

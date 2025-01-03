param (
    [string]$Version,
    [string]$BuildNumber
)

# Define the root directory and the target directory
$rootDirectory = "$(Get-Location)"
$targetDirectory = "$rootDirectory\code"

# Define the folder to be zipped
$folderToZip = "$rootDirectory\BlizzardInterfaceCode"

# Ensure version and build number are provided
if (-not $Version -or -not $BuildNumber) {
    Write-Output "Both version and build number must be provided"
    exit
}

# Define the zip file name
$zipFileName = "BlizzardInterfaceCode-$Version.$BuildNumber.zip"

# Define the full path for the zip file
$zipFilePath = "$targetDirectory\$zipFileName"

# Check if the folder exists
if (Test-path $folderToZip) {
    # Create the target directory if it doesn't exist
    if (-not (Test-Path $targetDirectory)) {
        New-Item -ItemType Directory -Path $targetDirectory
    }

    # Create the zip file
    Compress-Archive -Path $folderToZip -DestinationPath $zipFilePath
    Write-Output "Folder zipped and moved to $zipFilePath"
} else {
    Write-Output "Folder $folderToZip does not exist"
    exit 1
}

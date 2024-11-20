param (
    [string]$Version,
    [string]$BuildNumber,
    [string]$Action
)

# Define the root directory and the target directory
$rootDir = "$(Get-Location)"
$targetDir = "$rootDir\code"

# Define the zip file name
$zipFileName = "BlizzardInterfaceCode-$Version.$BuildNumber.zip"

# Define the full path for the zip file
$zipFilePath = "$targetDir\$zipFileName"

# Define the unpacked folder path
$unpackedFolderPath = "$targetDir\BlizzardInterfaceCode-$Version.$BuildNumber"

if ($Action -eq "unpack") {
    # Check if the zip file exists
    if (Test-Path $zipFilePath) {
        # Unpack the zip file
        Expand-Archive -Path $zipFilePath -DestinationPath $unpackedFolderPath

        Write-Output "Folder unpacked to $unpackedFolderPath"
    } else {
        Write-Output "Zip file $zipFilePath does not exist."
    }
} elseif ($Action -eq "delete") {
    # Check if the unpacked folder exists
    if (Test-Path $unpackedFolderPath) {
        # Delete the unpacked folder
        Remove-Item -Recurse -Force -Path $unpackedFolderPath

        Write-Output "Folder $unpackedFolderPath deleted."
    } else {
        Write-Output "Folder $unpackedFolderPath does not exist."
    }
} else {
    Write-Output "Invalid action. Use 'unpack' or 'delete'."
}
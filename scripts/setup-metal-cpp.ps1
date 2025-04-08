<#
.SYNOPSIS
    Script to download and extract Metal-cpp sources
.DESCRIPTION
    Download sources from https://developer.apple.com/metal/cpp/ and extract them to the designated folder

.EXAMPLE
    PS> ./setup-metal-cpp.ps1 -Folder "externals"
#>
using namespace System
param
(
    [String]$Folder = "externals",
    [String]$FileName = "metal-cpp_macOS15.2_iOS18.2.zip"
)

$Candidates = @(
    "metal-cpp_macOS15.2_iOS18.2.zip",
    "metal-cpp_macOS15_iOS18.zip",
    "metal-cpp_macOS15_iOS18-beta.zip",
    "metal-cpp_macOS14.2_iOS17.2.zip",
    "metal-cpp_macOS14_iOS17-beta.zip",
    "metal-cpp_macOS13.3_iOS16.4.zip",
    "metal-cpp_macOS13_iOS16.zip",
    "metal-cpp_macOS12_iOS15.zip"
)
if ($Candidates -notcontains $FileName) {
    Write-Warning "The '$FileName' is not recognized. Please check the file exists in https://developer.apple.com/metal/cpp/"
    Write-Host "The known values are: $($Candidates -join ', ')"
}

# Download if not exists
if ($(Test-Path -Path $FileName) -eq $false) {
    [Uri]$Remote = "https://developer.apple.com/metal/cpp/files/${FileName}"
    Invoke-WebRequest -Uri $Remote -OutFile $FileName
}

# Overwrite existing files
Expand-Archive -Path $FileName -DestinationPath $Folder -Force

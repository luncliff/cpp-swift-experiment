<#
.SYNOPSIS
    Script to download and extract Metal-cpp sources
.DESCRIPTION
    Download sources from https://developer.apple.com/metal/cpp/ and extract them to "externals/" folder

.EXAMPLE
    PS> ./setup-metal-cpp.ps1 -Folder "externals"
#>
using namespace System
param
(
    [String]$Folder = "externals",
    [String]$FileName = "metal-cpp_macOS13_iOS16.zip"
)

# Download if not exists
if ($(Test-Path -Path $FileName) -eq $false) {
    [Uri]$Remote = "https://developer.apple.com/metal/cpp/files/${FileName}"
    Invoke-WebRequest -Uri $Remote -OutFile $FileName
}

# Overwrite existing files
Expand-Archive -Path $FileName -DestinationPath $Folder -Force

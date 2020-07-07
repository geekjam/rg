#!/usr/bin/env pwsh

$version = '12.1.1'
$APP = 'rg'
$url = "https://github.com/BurntSushi/ripgrep/releases/download/$version/"
if ($env:china -eq 1)
{
	$url = "https://github.wanvi.net/https:/github.com/BurntSushi/ripgrep/releases/download/$version/"
}
$output = "$PSScriptRoot\bin\rg.zip"

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

if ([Environment]::Is64BitOperatingSystem) {
  $file_name = "ripgrep-$version-x86_64-pc-windows-msvc"
} else {
  $file_name = "ripgrep-$version-i686-pc-windows-msvc"
}

$url += "$file_name.zip"

if (Test-Path -LiteralPath $output) {
  Remove-Item -Force -LiteralPath $output
}

echo "Downloading $url, please wait a second......"

$start_time = Get-Date

(New-Object System.Net.WebClient).DownloadFile($url, $output)

Expand-Archive -ErrorAction SilentlyContinue "$PSScriptRoot\bin\rg.zip" "$PSScriptRoot\bin\"
Copy-Item "$PSScriptRoot\bin\$file_name\rg.exe" "$PSScriptRoot\bin\"
Remove-Item -Recurse -Force "$PSScriptRoot\bin\$file_name\"
Remove-Item -Force $output

Write-Output "Download the Rg binary successfully, time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

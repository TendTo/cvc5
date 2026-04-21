#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ImageTag = 'qest-formats-ae:2026'
$ImageTar = Join-Path $ScriptDir 'qest-formats-ae-image.tar.gz'
$InstancesDir = Join-Path $ScriptDir 'instances'

if (-not (Test-Path -LiteralPath $InstancesDir)) {
  New-Item -ItemType Directory -Path $InstancesDir | Out-Null
}

# Load docker image from tar if needed.
& docker image inspect $ImageTag *> $null
$imageExists = ($LASTEXITCODE -eq 0)
if (-not $imageExists -and (Test-Path -LiteralPath $ImageTar)) {
  Write-Host "[artifact] Loading docker image from $ImageTar"
  & docker load -i $ImageTar *> $null
}

Write-Host "[artifact] Running dlinear"
& docker run --rm -v "${InstancesDir}:/instances" --entrypoint ./binary_impl.sh $ImageTag $args

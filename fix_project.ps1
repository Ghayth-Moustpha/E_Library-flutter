Write-Host "Fixing Flutter project configuration..." -ForegroundColor Green

# Remove problematic files
if (Test-Path "android\build.gradle.kts") {
    Remove-Item "android\build.gradle.kts" -Force
    Write-Host "Removed build.gradle.kts" -ForegroundColor Yellow
}

# Backup lib folder
if (Test-Path "lib") {
    Copy-Item "lib" "lib_backup" -Recurse -Force
    Write-Host "Backed up lib folder" -ForegroundColor Yellow
}

# Remove and recreate android folder
if (Test-Path "android") {
    Remove-Item "android" -Recurse -Force
    Write-Host "Removed android folder" -ForegroundColor Yellow
}

# Recreate project
flutter create . --platforms android
Write-Host "Recreated Android configuration" -ForegroundColor Green

# Restore lib folder
if (Test-Path "lib_backup") {
    Remove-Item "lib" -Recurse -Force
    Move-Item "lib_backup" "lib"
    Write-Host "Restored lib folder" -ForegroundColor Green
}

# Create proper pubspec.yaml
$pubspecContent = @"
name: driving_dataset_collector
description: A Flutter app for collecting driving datasets.

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+5
  geolocator: ^9.0.2
  permission_handler: ^11.0.1
  path_provider: ^2.1.1
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
"@

$pubspecContent | Out-File -FilePath "pubspec.yaml" -Encoding UTF8
Write-Host "Updated pubspec.yaml" -ForegroundColor Green

# Get dependencies and clean
flutter pub get
flutter clean

Write-Host "Project fixed! Now run: flutter run" -ForegroundColor Green
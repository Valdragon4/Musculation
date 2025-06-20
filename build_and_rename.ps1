# Lire la version depuis pubspec.yaml
$pubspec = Get-Content .\pubspec.yaml
$versionLine = $pubspec | Select-String '^version:'
$version = $versionLine -replace 'version:\s*', '' -replace '\+.*', ''
$version = $version.Trim()

# Construire l'APK
flutter build apk --release

# Chemin de sortie par défaut
$apkPath = '.\build\app\outputs\flutter-apk\app-release.apk'
$newName = "muscu-$version.apk"

# Renommer l'APK
if (Test-Path $apkPath) {
    Rename-Item -Path $apkPath -NewName $newName -Force
    Write-Host "APK renommé en $newName"
} else {
    Write-Host "APK non trouvé à l'emplacement attendu : $apkPath"
}
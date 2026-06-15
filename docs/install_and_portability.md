# Backlog Vault v1 install and portability notes

Version: `0.1.0+1`

Final RC artifact names:

- `dist\BacklogVault-windows-x64-v0.1.0.zip`
- `dist\BacklogVault-android-v0.1.0.apk`

Backlog Vault is local-first. The app data, media files, API keys, and backups live on each device unless you move them explicitly.

## Windows ZIP install

1. Build the app:

   ```powershell
   flutter build windows
   ```

2. Create the portable ZIP:

   ```powershell
   .\tool\package_windows.ps1 -SkipBuild
   ```

   Omit `-SkipBuild` if you want the script to run `flutter build windows` first.

3. Extract `dist\BacklogVault-windows-x64-v0.1.0.zip` anywhere you want to run the app.
4. Launch `backlog_vault.exe` from the extracted folder.

The ZIP contains the complete Flutter Windows release folder: executable, DLLs, native assets, and `data`.

## Windows updates

Before replacing an older app folder, create a `.vaultbackup` or `.vaultbackup.enc` from Settings > Datos y backups.

The portable app folder is not the same as the user data folder. Replacing the app binaries should not delete your library, but a backup before updating is the safest workflow.

## Data locations

Backlog Vault stores its SQLite database and media under the platform app support area through Flutter plugins. The exact path is OS-managed and may differ between Windows and Android versions.

Media files are stored with relative paths in the database. To move data between devices, use Backlog Vault backups instead of copying individual files.

## Android APK install

Build the APK:

```powershell
flutter build apk
```

The generated APK is at:

```text
build\app\outputs\flutter-apk\app-release.apk
```

For the RC package, copy it to:

```text
dist\BacklogVault-android-v0.1.0.apk
```

This v1 APK uses the current local release configuration, signed with debug signing for personal installation/testing. It is not a Play Store release package.

The Android project currently uses Android Gradle Plugin 8.13.1 with legacy Kotlin plugin support because one dependency still applies the Kotlin Gradle Plugin path. `flutter build apk` may print a non-blocking warning about future built-in Kotlin migration.

Install it manually on a test phone or run it from Flutter when a device is connected:

```powershell
flutter run -d android
```

## Moving data between PC and Android

Use `.vaultbackup` or `.vaultbackup.enc`:

1. On the source device, create a backup from Settings > Datos y backups.
2. Move the backup file manually to the target device.
3. Restore it from Settings > Datos y backups on the target device.

There is no automatic sync in this release.

API keys are device-local. After restoring on another device, configure RAWG, IGDB/Twitch and SteamGridDB credentials again if you want external metadata or cover search there.

## Secrets and API keys

Backups and exports do not include RAWG keys, SteamGridDB keys, IGDB Client Secret, IGDB access tokens, or secure storage values.

After restoring on another device, configure provider credentials again from Settings if you want metadata or cover search on that device.

## Privacy reminder

`.vaultbackup` is not encrypted. Use `.vaultbackup.enc` when the file may leave your device or include sensitive notes.

The local SQLite database and media folder are not encrypted at rest in this release.

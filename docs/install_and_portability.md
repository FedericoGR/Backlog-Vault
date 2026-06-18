# Backlog Vault install and portability

Version: `0.1.0+3`
Release candidate: `v0.1.0-rc3`

Backlog Vault is local-first. App data, media, provider credentials, and language preferences live on each device unless explicitly moved through a backup.

## Windows

Build the release folder:

```powershell
flutter build windows
```

Create a portable ZIP without rebuilding:

```powershell
.\tool\package_windows.ps1 -SkipBuild
```

Extract the complete ZIP and launch `backlog_vault.exe`. The executable, DLLs, native assets, and `data` folder must remain together.

The portable application folder is not the user-data folder. Replacing the app binaries should not remove the library, but create a `.vaultbackup.enc` before every update.

## Android

Build the APK:

```powershell
flutter build apk
```

Flutter writes the release APK under:

```text
build\app\outputs\flutter-apk\app-release.apk
```

The current APK configuration is for local personal installation and QA, not Play Store publication. Android only accepts an in-place update when package identity and signing key are compatible. If a differently signed APK requires uninstalling the previous app, export an encrypted backup first because uninstalling may remove app-local data.

## Data locations

SQLite and media are stored in the OS-managed app support directory. Exact paths differ between Windows and Android. Media paths stored in SQLite are relative; do not move individual database or media files between devices.

The selected UI language is stored through platform preferences. It is device-local and is not included in the main SQLite database or backups.

## PC ↔ Android transfer

Automatic sync does not exist in RC3. Use the supported manual workflow:

1. Create `.vaultbackup.enc` on the source device.
2. Move the file through a channel you control.
3. Restore it on the destination device with the password.
4. Configure RAWG, IGDB/Twitch, and SteamGridDB credentials again on that device.

Plain `.vaultbackup` also works but is not encrypted and may expose personal notes and library data.

## Restore guarantees and limits

- A safety backup is created before restore.
- Rows in the backup are inserted or updated.
- Current rows absent from the backup are soft-deleted.
- Existing media is not hard-deleted during restore.
- Restore is complete/conservative, not a field-level merge or sync conflict resolver.
- Provider credentials and secure-storage values are never restored.

## Security reminder

The local SQLite database and media folder are not encrypted at rest in RC3. Use OS device protection and encrypted backups. Never include real API credentials, `.secure` files, tokens, or keystores in an app package, backup example, test, log, or repository commit.

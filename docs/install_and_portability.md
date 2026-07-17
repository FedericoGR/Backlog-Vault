# Backlog Vault install and portability

App version: `0.3.0+5` (unchanged during E2)

Backlog Vault is an offline, single-device application. SQLite, managed media,
provider credentials, and language preferences stay on the device unless the
user explicitly exports and moves a backup.

## Windows

Build the release folder:

```powershell
flutter build windows --release
```

Create a portable ZIP without rebuilding:

```powershell
.\tool\package_windows.ps1 -SkipBuild
```

Extract the complete ZIP and launch `backlog_vault.exe`. The executable, DLLs,
native assets, and `data` folder must remain together. The portable application
folder is not the user-data folder; create a `.vaultbackup.enc` before replacing
binaries or moving to another computer.

## Android

Build the release APK:

```powershell
flutter build apk --release
```

The APK is written to `build\app\outputs\flutter-apk\app-release.apk`. It is a
personal/QA package, not a Play Store artifact. An in-place update requires the
same package identity and compatible signing key. Never uninstall or clear app
data as part of an update: make an encrypted backup first if replacement cannot
be proven safe.

Backlog Vault does not request camera access. `INTERNET` remains present only
for user-triggered optional metadata and cover providers.

## Local data

- SQLite and managed media live in the OS application-support directory.
- Media paths in SQLite are relative; do not copy the database without its
  matching managed-media tree.
- The selected language is stored in platform preferences and is not part of
  the library database or backup.
- RAWG, IGDB/Twitch, and SteamGridDB credentials stay in OS secure storage and
  are excluded from library exports and backups.
- On first schema-6 startup, only the explicit legacy Sync secure-storage keys
  are removed; external credentials and unknown keys are preserved.

## Moving a library between devices

There is no pairing, QR, LAN transport, background job, or cross-device Sync.
Use an explicit backup:

1. Create `.vaultbackup.enc` on the source device.
2. Move the file through a channel you control.
3. Restore it on the destination with its password.
4. Configure optional provider credentials again on the destination.

Plain `.vaultbackup` also works but is not encrypted and may expose personal
notes and library data. `.vaultbackup.enc` includes the ten functional entity
families and managed media. Historical `.vaultsync` and `.vaultpair` formats
are no longer accepted or produced by the active application.

## Restore guarantees and limits

- A safety backup is created before restore.
- Rows in the backup are inserted or updated.
- Current rows absent from the backup are soft-deleted.
- Existing media is not hard-deleted during restore.
- Provider credentials and secure-storage values are never restored.
- Restore is a complete/conservative snapshot operation, not a field-level
  merge between devices.

## Security reminder

The local SQLite database and media folder are not encrypted at rest. Use OS
device protection and encrypted backups. Never include real API credentials,
tokens, `.secure` files, databases, backups, or keystores in an app package,
test, log, screenshot, or repository commit.

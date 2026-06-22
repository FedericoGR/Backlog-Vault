# Backlog Vault install and portability

Version: `0.1.0+3`
Release candidate: `v0.1.0-rc3`

Backlog Vault is local-first. App data, media, provider credentials, and language preferences live on each device unless library data is explicitly moved through a backup or encrypted sync package.

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

Automatic, LAN, and cloud sync do not exist yet. Manual pairing and manual file transfer provide three distinct workflows.

For full migration or disaster recovery, including media:

1. Create `.vaultbackup.enc` on the source device.
2. Move the file through a channel you control.
3. Restore it on the destination device with the password.
4. Configure RAWG, IGDB/Twitch, and SteamGridDB credentials again on that device.

Plain `.vaultbackup` also works but is not encrypted and may expose personal notes and library data.

For exchanging library changes between existing installations:

1. In **Settings → Sync**, export a `.vaultsync` package and choose a strong password.
2. Move the file manually to the other device.
3. Import it with the same password and inspect the preview.
4. Apply safe changes. Duplicate changes are skipped and conflicts are reported without overwriting local values.

`.vaultsync` is encrypted and contains no provider credentials or secure-storage data. It is not a backup, and this stage does not carry media file bytes. Cover-related changes remain pending so the destination never selects a missing image. A forgotten package password cannot be recovered.

To pair installations and avoid entering a password for every later package:

1. Create a sync group on the first device under **Settings → Sync**.
2. Export a `.vaultpair` invitation protected with a temporary password. It expires after 24 hours.
3. Move the invitation to the second device and import it with that password.
4. Exchange group-encrypted `.vaultsync` files manually. Preview and conflict rules remain unchanged.

The random group key is inside the encrypted invitation and is then stored only in OS secure storage. SQLite stores its public key ID, never the key. Share the invitation file and temporary password through separate trusted channels. Pairing does not start LAN or automatic sync. If secure storage is erased or a device leaves the group, it must be paired again. API keys and media files never travel in `.vaultpair`.

## Restore guarantees and limits

- A safety backup is created before restore.
- Rows in the backup are inserted or updated.
- Current rows absent from the backup are soft-deleted.
- Existing media is not hard-deleted during restore.
- Restore is complete/conservative, not a field-level merge or sync conflict resolver.
- Provider credentials and secure-storage values are never restored.
- Sync identities, counters, and change history are device-local and are not cloned by restore.

## Security reminder

The local SQLite database and media folder are not encrypted at rest in RC3. Use OS device protection and encrypted backups. Never include real API credentials, `.secure` files, tokens, or keystores in an app package, backup example, test, log, or repository commit.

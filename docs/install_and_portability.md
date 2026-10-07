# Backlog Vault install and portability

App version: `1.0.0-rc2+7`.

Backlog Vault is an offline, single-device application. SQLite, managed media,
provider credentials, and language preferences stay on the device. The product
can export library information to a readable JSON file, but it does not provide
automatic restore or complete device recovery.

## Windows

Build the release folder:

```powershell
flutter build windows --release
```

Create the portable application ZIP without rebuilding:

```powershell
.\tool\package_windows.ps1 -SkipBuild
```

Without `-SkipBuild`, the script performs a clean release build. It copies only
the executable, release DLLs, generated native manifest, and `data` directory;
then validates a deterministic ZIP and writes SHA-256 beside it. The target
machine needs a compatible Microsoft Visual C++ runtime.

Extract the complete ZIP and launch `backlog_vault.exe`. The executable, DLLs,
native assets, runtime `data` folder, and persistent `userdata` folder must
remain together. SQLite, managed media, language preferences, and encrypted
provider credentials are all written below `userdata`. Close the app before
copying the complete folder to another location or making a backup.

## Android

Build the release APK:

```powershell
flutter build apk --release
```

For the checksummed arm64 and universal personal-distribution artifacts, use:

```powershell
.\tool\package_android.ps1
```

The default packages arm64-v8a for modern Motorola/Android hardware plus a
universal fallback. `-Mode All` also emits armeabi-v7a and x86_64. The script
never installs an APK. E7 performs the physical in-place QA.

The `v1.0.0-rc2` release APK is `Backlog-Vault-v1.0.0-rc2-Android.apk`.
It uses Android debug signing for personal/QA installation and is not a Play
Store artifact. An in-place update requires the same package identity and a
compatible signing key. Never uninstall or clear app data as part of an update
when the installation contains important data.
The JSON export is not an automatic restore format.

Backlog Vault does not request camera or broad storage access. `INTERNET`
remains present only for user-triggered optional metadata and cover providers.
The export destination is selected through the operating system document
picker.

## Local data

- On Windows, SQLite and managed media live in the portable `userdata`
  directory beside the executable. On Android they use the OS
  application-support directory.
- Media paths in SQLite are relative; the JSON export never exposes those
  paths.
- On Windows, the selected language is stored in `userdata/settings.json`; on
  Android it uses platform preferences. It is not part of SQLite or JSON
  exports.
- On Windows, RAWG, IGDB/Twitch, and SteamGridDB credentials are encrypted with
  the current Windows user's DPAPI key and stored in
  `userdata/flutter_secure_storage.dat`. They remain excluded from library
  exports and may not decrypt under a different Windows user or PC.
- On first schema-6 startup, only the explicit legacy Sync secure-storage keys
  are removed; external credentials and unknown keys are preserved.

## Exporting library information

Open **Settings → Library data → Export library**. Backlog Vault builds a
consistent read-only snapshot, encodes it as pretty-printed UTF-8 JSON, and
asks the operating system where to save
`backlog-vault-library-YYYYMMDD-HHmmss.json`.

The document includes games, library entries, playthroughs, catalogs,
relationships, saved views, applied metadata references, and descriptive media
records. It excludes:

- image bytes and local file paths;
- provider credentials, tokens, and secure-storage values;
- the SQLite database, caches, and logs;
- historical Sync data;
- device-specific recovery state.

Cancelling the picker does not create a file and is not treated as an error.
There is no JSON import, merge, or restore flow in the current Offline product.

## Portability limits

The JSON is suitable for preservation, inspection, and user-controlled data
processing. It is not a complete backup: local images are not embedded, and
Backlog Vault cannot reconstruct another installation from the file during
this cycle. Keep OS-level device protection and an independent recovery plan
for any library whose loss would matter.

Historical `.vaultbackup`, `.vaultbackup.enc`, `.vaultsync`, and `.vaultpair`
formats are no longer accepted or produced by the active application. Their
implementation remains only in Git history and the external audit bundle.

## Security reminder

The local SQLite database and media folder are not encrypted at rest. Never
include real API credentials, tokens, `.secure` files, databases, exported JSON
files, old backup packages, or keystores in an application package, test, log,
screenshot, or repository commit.

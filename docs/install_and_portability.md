# Backlog Vault install and portability

App version: `0.3.0+5`.

Backlog Vault is an offline, single-device application. SQLite, managed media,
provider credentials, and language preferences stay on the device. The product
can export library information to a readable JSON file, but it does not provide
automatic restore or complete device recovery.

## Windows

Build the release folder:

```powershell
flutter build windows --release
```

Create a portable application ZIP without rebuilding:

```powershell
.\tool\package_windows.ps1 -SkipBuild
```

Extract the complete ZIP and launch `backlog_vault.exe`. The executable, DLLs,
native assets, and `data` folder must remain together. The portable application
folder is separate from the OS-managed user-data folder. Replacing binaries
must not delete or move that user-data folder.

## Android

Build the release APK:

```powershell
flutter build apk --release
```

The APK is written to `build\app\outputs\flutter-apk\app-release.apk`. It is a
personal/QA package, not a Play Store artifact. An in-place update requires the
same package identity and a compatible signing key. Never uninstall or clear
app data as part of an update when the installation contains important data.
The JSON export is not an automatic restore format.

Backlog Vault does not request camera or broad storage access. `INTERNET`
remains present only for user-triggered optional metadata and cover providers.
The export destination is selected through the operating system document
picker.

## Local data

- SQLite and managed media live in the OS application-support directory.
- Media paths in SQLite are relative; the JSON export never exposes those
  paths.
- The selected language is stored in platform preferences and is not part of
  the library database or JSON export.
- RAWG, IGDB/Twitch, and SteamGridDB credentials stay in OS secure storage and
  are excluded from library exports.
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

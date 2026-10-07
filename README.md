<p align="center">
  <img src="docs/images/backlog-vault-logo.png" alt="Backlog Vault" width="600">
</p>

<p align="center">An offline personal video game log for Windows and Android.</p>

<p align="center"><a href="README.es.md">Español</a></p>

Backlog Vault keeps a personal record of the games you've played. Browse your library by year and record completion, hours played, rating, platform, and notes. Your library and covers stay on your device; online metadata sources are optional.

## Features

- Annual cover gallery, with access to games whose played year is unknown.
- One personal record per game: completed or not completed, played year, optional completion date, hours played, personal rating, played platform, and notes.
- Search and simple filters for completion, played platform, and rating. Completed games with dates appear newest first.
- Yearly statistics, favorites, and a breakdown of where you played.
- Manual game entry, optional RAWG and IGDB metadata, and covers from IGDB, SteamGridDB, or local files.
- Notion CSV import and readable JSON library export.
- English and Spanish, with system, light, and dark themes.

## Screenshots

Screenshots of the current interface will be added here.

<!-- Replace these placeholders with screenshots once the files are available:
![Annual game gallery](docs/images/screenshots/library.png)
![Personal game record](docs/images/screenshots/game-detail.png)
![Yearly statistics](docs/images/screenshots/statistics.png)
-->

## Download

Check [Releases](https://github.com/FedericoGR/Backlog-Vault/releases) for published builds and release notes.

- **Windows portable ZIP:** extract the complete archive and run `backlog_vault.exe`.
- **Android APK:** install the APK on a compatible device. The current RC uses debug signing for personal testing.

See [installation and portability](docs/install_and_portability.md) for updating, local data, and backups.

## Building

Use Flutter 3.44.1 stable with the Windows or Android toolchain configured. Run `flutter doctor` to check your setup.

```sh
flutter pub get
flutter run
```

To build a release:

```sh
flutter build windows --release
flutter build apk --release
```

Build and packaging scripts are available in `tool/`. See the [release build guide](docs/build/release_build_and_packaging.md).

## Project status

Current release candidate: **v1.0.0-rc2** (`1.0.0-rc2+7`). Windows is the primary tested target. Android is available and continues to receive usability polish.

## Contributing

Bug reports and focused pull requests are welcome. Include your platform and steps to reproduce the issue. For code changes, run `flutter analyze` and `flutter test` before submitting.

## License

No project license has been specified.

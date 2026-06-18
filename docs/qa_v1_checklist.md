# Backlog Vault v1 QA checklist

Use a disposable library or test backup. Never use real provider credentials in screenshots, fixtures, logs, or commits.

## RC3 automated validation

Target: `v0.1.0-rc3`, version `0.1.0+3`, 2026-06-18.

- [x] `flutter pub get`
- [x] `dart run build_runner build`
- [x] `flutter analyze`
- [x] `flutter test`
- [x] `flutter build windows`
- [x] `flutter build apk`
- [x] Secret and artifact scan

Update these boxes only from the final validation run.

## i18n — Windows and Android

- [ ] Fresh install follows an English system locale.
- [ ] Fresh install follows a Spanish system locale.
- [ ] Settings → Language offers System, Español, and English.
- [ ] Selecting English updates navigation and visible page content immediately.
- [ ] Selecting Spanish updates navigation and visible page content immediately.
- [ ] Selecting System resumes OS locale behavior.
- [ ] The selection survives app restart on the same device.
- [ ] The selected language is not transferred through backup/restore.
- [ ] Game names and canonical provider/platform names are not translated.
- [ ] Long English labels do not overflow on phone or desktop widths.

## Windows manual smoke test

- [ ] App opens from a release build without touching production data unexpectedly.
- [ ] Create, edit, and soft-delete a game.
- [ ] Table, gallery, list, filters, columns, and saved views work.
- [ ] Home and Statistics render with populated and empty libraries.
- [ ] Notion CSV import reaches preview and result.
- [ ] RAWG/IGDB metadata dialogs work with test credentials.
- [ ] IGDB/SteamGridDB/local cover flows work with test data.
- [ ] Bulk metadata/cover import preserves protected personal fields.
- [ ] Plain and encrypted backup creation work.
- [ ] Plain and encrypted restore create a safety backup.
- [ ] Wrong encrypted-backup password fails without modifying data.

## Android manual smoke test

- [ ] APK installs or updates with the expected local signing identity.
- [ ] App opens on a phone-size viewport.
- [ ] Bottom navigation, dialogs, filters, and forms fit without overflow.
- [ ] Create/edit/detail and gallery flows work.
- [ ] CSV picker, backup export, and restore pickers work.
- [ ] Metadata, covers, bulk import, Home, and Statistics work.
- [ ] System dark mode uses the OLED-friendly theme.

## Release assertions

- [x] No automatic sync is present in RC3.
- [x] No account or backend is required.
- [x] Provider credentials do not travel in backups.
- [x] Plain backups remain unencrypted and clearly documented.
- [x] Encrypted backups require their password.
- [x] Restore keeps soft-delete semantics and does not hard-delete media.

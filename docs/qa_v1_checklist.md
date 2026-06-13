# Backlog Vault v1 QA checklist

Use a test library or a disposable backup when possible. Do not use real provider secrets in screenshots, logs, fixtures, or commits.

## Windows

- [ ] App opens from `flutter run -d windows`.
- [ ] App opens from the portable ZIP extracted from `dist`.
- [ ] Create a game.
- [ ] Edit a game.
- [ ] Delete a game with soft delete flow.
- [ ] Import a Notion CSV fixture.
- [ ] Search metadata with IGDB.
- [ ] Search metadata with RAWG if a key is configured.
- [ ] Save an IGDB cover.
- [ ] Save a SteamGridDB cover if a key is configured.
- [ ] Change an existing cover without deleting the old file.
- [ ] Run bulk metadata import through preview and confirmation.
- [ ] Toggle table and gallery.
- [ ] Use filters, search, sort, and saved views.
- [ ] Open Home.
- [ ] Open Statistics.
- [ ] Create a normal `.vaultbackup`.
- [ ] Create an encrypted `.vaultbackup.enc`.
- [ ] Restore a normal backup.
- [ ] Restore an encrypted backup with the correct password.
- [ ] Confirm wrong encrypted-backup password fails safely.
- [ ] Switch system theme or inspect dark/light theme behavior.
- [ ] Save and delete external API keys from Settings.

## Android

- [ ] App installs from `flutter build apk` output.
- [ ] App opens on a physical device or emulator.
- [ ] Navigation works on phone-size screen.
- [ ] Create a game.
- [ ] Edit a game.
- [ ] Import CSV through Android file picker.
- [ ] Export a normal backup.
- [ ] Export an encrypted backup.
- [ ] Restore a normal backup.
- [ ] Restore an encrypted backup.
- [ ] Save and delete API keys from Settings.
- [ ] Search metadata with IGDB if credentials are configured.
- [ ] Save a cover from IGDB if credentials are configured.
- [ ] Open gallery and detail cover views.
- [ ] Open Statistics.
- [ ] Verify system dark theme uses the OLED dark theme.

## Release notes to verify

- [ ] No automatic sync exists.
- [ ] API keys do not travel in backups.
- [ ] `.vaultbackup` is not encrypted.
- [ ] `.vaultbackup.enc` requires the password to restore.
- [ ] Android APK is local/debug-signed for personal testing, not store release.

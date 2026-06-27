# QR pairing and LAN connection notes

Backlog Vault QR support is a UX layer over the existing sync model. It does not introduce discovery, cloud transport, background sync, or a new trust model.

## Pairing QR

- The QR contains a versioned wrapper around the encrypted `.vaultpair` invitation payload.
- The invitation still requires the temporary password/passphrase used by the existing pairing flow.
- The sync group key is inside the encrypted invitation and never appears in clear text in the QR.
- If the QR payload is too large for reliable scanning, use the `.vaultpair` file export/import fallback.
- File import, scan, and paste-code flows all feed the same pairing importer.

Do not put API keys, secure-storage data, backups, media files, database data, passwords, or clear-text group keys into QR payloads.

## LAN connection QR

- The LAN QR contains host/IP, port, session code, sync group ID, key ID, protocol version, and timestamps.
- It does not contain the sync group key, passwords, library data, provider credentials, backups, or media.
- The existing LAN sync challenge/proof and group-encrypted `.vaultsync` exchange remain the actual security boundary.
- The client validates payload type, QR format version, sync protocol version, group ID, key ID, host, port, and session code before filling the connection form.

## Platform behavior

- Android can scan QR codes and may request camera permission.
- Windows can display QR codes and use paste/manual entry; camera scanning is not required.
- Manual fallbacks remain available everywhere: `.vaultpair` files, text paste, and manual IP/port/code entry.

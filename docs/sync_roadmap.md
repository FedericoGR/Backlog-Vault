# Secure PC ↔ Android sync roadmap

Status: deterministic sync foundation, encrypted `.vaultsync` packages, manual `.vaultpair` device pairing with secure-storage group keys, manual paired LAN sync, LAN media transfer by hash, and QR helpers for pairing/LAN connection UX are implemented. Automatic discovery, background sync, advanced conflict-resolution UI, and cloud transport remain future work.

## Principles

1. **Local-first:** SQLite and media on each device remain authoritative local working copies.
2. **No account required:** pairing and sync must work without a Backlog Vault backend.
3. **End-to-end confidentiality:** sync payloads are encrypted before transport and decrypted only by a user holding the package password or a paired device holding the group key.
4. **Conservative writes:** ambiguous conflicts are visible; no silent hard delete or last-writer-wins data loss.
5. **Transport independence:** package format, encryption, and merge logic must not depend on LAN, file sharing, or future cloud transport.
6. **Recoverability:** every apply operation should be previewable and protected by a local safety snapshot.

## Proposed stages

### Stage 1 — Manual encrypted sync packages

Implemented in E19/E20:

- A versioned `BVS1` package is separate from full backup/restore.
- PBKDF2-HMAC-SHA256 derives a per-package AES-256-GCM key from the user password using a random salt; every package also has a random nonce and authentication tag.
- The encrypted payload carries device metadata, logical change IDs, causal vectors, tombstones, entity state, and an informational media manifest.
- Import always previews first. Duplicate changes are skipped, provably safe changes are applied transactionally, and ambiguous conflicts are reported without silently overwriting local data.
- Applying remote changes suppresses local echo and is idempotent by `changeId`.
- Media file bytes are deliberately excluded. Media changes remain pending and cannot create a selected cover that points to a missing file.

Current limitations:

- The password is not stored and a forgotten password makes that package unrecoverable.
- Every export currently contains all known changes; peer acknowledgements and incremental export arrive with pairing.
- Conflict resolution is summary-only; conflicting values are preserved locally and skipped.
- `.vaultsync` is not a full backup. Use `.vaultbackup.enc` for complete migration or recovery, including media.

### Stage 2 — Device pairing

Implemented in E21:

- Create a logical sync group with a random 256-bit key that is never derived from provider credentials.
- Store the key only in platform secure storage; SQLite retains public group, key ID, and device metadata.
- Export/import a dedicated `BVP1` `.vaultpair` invitation encrypted with a temporary password and expiring after 24 hours.
- Keep legacy password-mode `.vaultsync` while allowing authenticated group-key packages without repeated password entry.
- Leave/revoke locally by deleting the group key without deleting the library or changelog.
- QR rendering/scanning is now available as a UX layer over the same encrypted invitation flow. The QR payload carries the encrypted invitation, not the group key in clear text. File import and paste/manual fallback remain available.

### Stage 3 — LAN transport

Implemented in E22/E23:

- Address a paired device manually on the local network with host IP, port, and a short session code.
- Run a temporary HTTP host/client session; the server shuts down when the session completes or is stopped.
- Authenticate session messages with HMAC-SHA256 proofs derived from the stored sync group key; the group key itself never travels.
- Exchange the same group-encrypted `.vaultsync` packages used by manual file sync.
- Keep the same package validation, preview/apply, idempotency, conflict, and safe pending-media behavior as manual sync.
- Treat LAN as untrusted: library payloads are still encrypted and authenticated before they leave the device.
- Transfer app-managed cover files by SHA-256 hash after the encrypted change-package exchange.
- Never trust remote file paths or file names; the receiver chooses the local media path and validates bytes before registering a cover asset.
- Accept only supported image bytes (JPEG, PNG, WebP), with per-file, per-session, and request-size limits.
- Keep media pending when the sender lacks the file, the hash does not match, bytes are truncated, the type is invalid, or the asset is not part of the expected manifest.

### Stage 3.5 — QR pairing and LAN connection UX

Implemented in E28:

- Render a QR for encrypted `.vaultpair` invitations and accept scan/paste import on the receiving device.
- Render a QR for LAN host sessions containing host/IP, port, temporary session code, sync group ID, key ID, protocol version, and timestamps.
- Keep the security model unchanged: LAN QR does not contain the sync group key, password, provider credentials, library data, backups, or media.
- Validate QR type, format version, sync protocol version, group ID, key ID, host, port, and session code before filling the LAN connection form.
- Keep manual fallbacks: `.vaultpair` files, text paste, and manual IP/port/code entry.
- Android can scan with the camera permission; Windows can display QR and use copy/paste/manual entry.

Current limitations:

- No mDNS, automatic discovery, background sync, cloud relay, arbitrary-file transfer, or media cleanup/compaction.
- The user must still start a host session manually. QR only avoids typing IP, port, and session code.

### Stage 4 — Optional cloud transport

- Consider only after manual and LAN sync are stable.
- Cloud storage must see ciphertext and minimal routing metadata only.
- The service must not hold plaintext sync keys.
- Account-free transports should remain supported.

## Data model direction

- Stable device IDs and operation/change IDs.
- Per-entity revision or change history for games, library entries, playthroughs, catalogs, links, media references, and soft deletes.
- Media addressed by cryptographic hash to deduplicate and verify content.
- Tombstones for deletes; never infer hard deletion from absence alone.
- Schema and package version gates with forward-incompatible rejection.
- Provider credentials, OAuth tokens, language, and other device preferences remain out of sync.

## Conflict policy

- Auto-merge independent changes where safety is provable.
- Surface same-field concurrent changes with both values, timestamps, and originating devices.
- Give personal notes, ratings, status, playthroughs, and cover replacement explicit conflict treatment.
- Preserve both media blobs until conflict resolution and cleanup are confirmed.
- Create a safety backup/snapshot before applying a package.
- Make repeated package application idempotent.

## Security requirements

- Authenticated encryption for every package.
- Random nonces and keys generated with platform cryptographic randomness.
- Key material only in memory as needed and persisted only in secure storage.
- Package size/count limits and archive path validation.
- Hash verification before media is accepted.
- Replay detection and monotonic or causal state checks.
- Secret redaction in user-visible and diagnostic errors.
- Test fixtures use dummy keys and synthetic libraries only.

## Recommended next deliverables

1. Completed: threat model, device identity, change schema, causal state, and tombstone rules.
2. Completed: versioned encrypted manual packages, preview, conservative apply, and cross-device fixtures.
3. Completed E21: manual pairing, group-key lifecycle in secure storage, group package authentication, and local leave/revocation.
4. Completed E22: authenticated manual LAN transport reusing the same package and apply engine.
5. Completed E22.5: LAN hardening, endpoint UX polish, timeout/error coverage, and adversarial socket tests.
6. Completed E23: hash-addressed LAN media-byte transfer for app-managed covers.
7. Completed E23.5: LAN media transfer hardening, path/content validation, and adversarial DB/temp-dir tests.
8. Completed E24/E25/E27: v0.2.0 release candidate packaging, GitHub publication, and stable promotion.
9. Completed E28: QR pairing and LAN connection UX with manual fallback and unchanged sync cryptography.
10. E30: `v0.3.0-rc1` packages the QR UX as a release candidate without changing `.vaultsync`, `.vaultpair`, LAN sync, media transfer, or Drift schema.
11. Future: real RC QA, conflict-resolution UX, performance profiling, recovery UX, automatic discovery, and post-v0.3 stabilization.

Each stage should preserve Windows, Android, metadata, covers, backup/restore, bulk import, gallery, statistics, and the current RC behavior before advancing.

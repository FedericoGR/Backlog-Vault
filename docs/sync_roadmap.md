# Secure PC ↔ Android sync roadmap

Status: deterministic sync foundation and password-encrypted manual `.vaultsync` packages are implemented. Pairing, network transport, conflict-resolution UI, and media-byte transfer remain future work.

## Principles

1. **Local-first:** SQLite and media on each device remain authoritative local working copies.
2. **No account required:** pairing and sync must work without a Backlog Vault backend.
3. **End-to-end confidentiality:** sync payloads are encrypted before transport and decrypted only by a user holding the package password; future pairing will replace manual passwords with managed sync keys.
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

- Pair Windows and Android with a QR code or short code.
- Establish a random sync key; never derive it from provider credentials.
- Store the sync key in platform secure storage on each device.
- Show paired-device identity and allow explicit revocation.
- Never include the sync key in backups, logs, analytics, or QR screenshots after pairing.

### Stage 3 — LAN transport

- Discover or address a paired device on the local network.
- Authenticate both endpoints before exchanging encrypted packages.
- Keep the same package validation, preview, and conflict engine as manual sync.
- Treat LAN as untrusted: encryption and authentication remain mandatory.

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
3. E21: pairing UX, group key lifecycle in secure storage, fingerprint verification, and revocation.
4. E22: authenticated LAN transport reusing the same package and apply engine.
5. E23: hash-addressed media-byte transfer and visible conflict-resolution workflows.
6. E24: performance, recovery, security, Windows/Android, and v0.2 stabilization.

Each stage should preserve Windows, Android, metadata, covers, backup/restore, bulk import, gallery, statistics, and the current RC behavior before advancing.

# Secure PC ↔ Android sync roadmap

Status: design proposal only. No sync code ships in v0.1.0 RC3.

## Principles

1. **Local-first:** SQLite and media on each device remain authoritative local working copies.
2. **No account required:** pairing and sync must work without a Backlog Vault backend.
3. **End-to-end confidentiality:** sync payloads are encrypted before transport and decrypted only on paired devices.
4. **Conservative writes:** ambiguous conflicts are visible; no silent hard delete or last-writer-wins data loss.
5. **Transport independence:** package format, encryption, and merge logic must not depend on LAN, file sharing, or future cloud transport.
6. **Recoverability:** every apply operation should be previewable and protected by a local safety snapshot.

## Proposed stages

### Stage 1 — Manual encrypted sync packages

- Define a versioned package separate from full backup/restore.
- Store device ID, logical change IDs, base revision, media hashes, and encrypted payload metadata.
- Export on one device, move manually, preview, and apply on the other.
- Reuse proven encryption primitives, but use a dedicated format and threat model rather than pretending a backup is a sync protocol.

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

1. Threat model and trust boundaries.
2. Sync identity/change schema with migrations and tombstone rules.
3. Versioned encrypted package specification and golden test vectors.
4. Deterministic diff/preview engine with conflict fixtures.
5. Manual export/import prototype using disposable databases.
6. Pairing UX and secure-storage key lifecycle.
7. Authenticated LAN transport.

Each stage should preserve Windows, Android, metadata, covers, backup/restore, bulk import, gallery, statistics, and the current RC behavior before advancing.

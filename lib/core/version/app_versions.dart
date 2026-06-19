/// Physical Drift schema version.
const databaseSchemaVersion = 5;

/// Version of the logical library document used by JSON and backups.
///
/// Sync-only tables are intentionally excluded, so adding them must not make
/// an otherwise compatible library backup unreadable by the v0.1 data model.
const logicalLibrarySchemaVersion = 4;

/// Reserved for the future sync package/application protocol.
const syncProtocolVersion = 1;

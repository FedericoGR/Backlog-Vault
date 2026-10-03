import 'schema_v5_fixture.dart';

/// A physical v6 schema, independent of the current generated Drift tables.
void createEmptySchemaV6(dynamic database) {
  createSchemaV5Fixture(database);
  for (final table in syncTableNames.reversed) {
    database.execute('DROP TABLE $table');
  }
  for (final table in functionalTableNames.reversed) {
    database.execute('DELETE FROM $table');
  }
  database.execute('PRAGMA user_version = 6');
}

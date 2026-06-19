import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Canonical JSON used for oplog payloads and hashes.
///
/// Nulls are retained. Map keys are sorted recursively. Dates are normalized
/// to UTC with ISO-8601 encoding. Integral doubles are normalized to integers,
/// and non-finite numbers are rejected.
class CanonicalJson {
  const CanonicalJson();

  String encode(Object? value) => jsonEncode(normalize(value));

  String sha256Hex(Object? value) =>
      sha256.convert(utf8.encode(encode(value))).toString();

  Object? normalize(Object? value) {
    if (value == null || value is bool || value is String || value is int) {
      return value;
    }
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Enum) return value.name;
    if (value is double) {
      if (!value.isFinite) {
        throw const FormatException(
          'Sync JSON does not support non-finite numbers.',
        );
      }
      if (value == 0) return 0;
      if (value == value.truncateToDouble()) return value.toInt();
      return value;
    }
    if (value is num) return normalize(value.toDouble());
    if (value is Iterable) {
      return value
          .map<Object?>((item) => normalize(item))
          .toList(growable: false);
    }
    if (value is Map) {
      final entries = <MapEntry<String, Object?>>[];
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw const FormatException('Sync JSON map keys must be strings.');
        }
        entries.add(MapEntry(entry.key as String, normalize(entry.value)));
      }
      entries.sort((a, b) => a.key.compareTo(b.key));
      return <String, Object?>{
        for (final entry in entries) entry.key: entry.value,
      };
    }
    throw FormatException('Unsupported sync JSON value: ${value.runtimeType}.');
  }
}

const canonicalJson = CanonicalJson();

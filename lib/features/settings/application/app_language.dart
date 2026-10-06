import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/app_data_directory.dart';

enum AppLanguagePreference { system, spanish, english }

extension AppLanguagePreferenceX on AppLanguagePreference {
  String get storageValue => switch (this) {
    AppLanguagePreference.system => 'system',
    AppLanguagePreference.spanish => 'es',
    AppLanguagePreference.english => 'en',
  };

  Locale? get locale => switch (this) {
    AppLanguagePreference.system => null,
    AppLanguagePreference.spanish => const Locale('es'),
    AppLanguagePreference.english => const Locale('en'),
  };
}

class AppLanguageController extends AsyncNotifier<AppLanguagePreference> {
  @override
  Future<AppLanguagePreference> build() async {
    final value = await ref.read(appLanguageStorageProvider).read();
    return _fromStorage(value);
  }

  Future<void> setPreference(AppLanguagePreference preference) async {
    state = AsyncData(preference);
    await ref
        .read(appLanguageStorageProvider)
        .write(
          preference == AppLanguagePreference.system
              ? null
              : preference.storageValue,
        );
  }

  AppLanguagePreference _fromStorage(String? value) => switch (value) {
    'es' => AppLanguagePreference.spanish,
    'en' => AppLanguagePreference.english,
    _ => AppLanguagePreference.system,
  };
}

abstract interface class AppLanguageStorage {
  Future<String?> read();

  Future<void> write(String? value);
}

class SharedPreferencesAppLanguageStorage implements AppLanguageStorage {
  static const _storageKey = 'app_language';

  @override
  Future<String?> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_storageKey);
  }

  @override
  Future<void> write(String? value) async {
    final preferences = await SharedPreferences.getInstance();
    if (value == null) {
      await preferences.remove(_storageKey);
    } else {
      await preferences.setString(_storageKey, value);
    }
  }
}

class PortableFileAppLanguageStorage implements AppLanguageStorage {
  static const _storageKey = 'app_language';

  @override
  Future<String?> read() async {
    final file = await _settingsFile();
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded[_storageKey] as String?;
      }
    } on Object {
      return null;
    }
    return null;
  }

  @override
  Future<void> write(String? value) async {
    final file = await _settingsFile();
    await file.parent.create(recursive: true);
    final values = <String, String>{};
    if (value != null) values[_storageKey] = value;
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(values),
      flush: true,
    );
  }

  Future<File> _settingsFile() async {
    final directory = await getBacklogVaultDataDirectory();
    return File('${directory.path}${Platform.pathSeparator}settings.json');
  }
}

final appLanguageStorageProvider = Provider<AppLanguageStorage>((ref) {
  return Platform.isWindows
      ? PortableFileAppLanguageStorage()
      : SharedPreferencesAppLanguageStorage();
});

final appLanguageProvider =
    AsyncNotifierProvider<AppLanguageController, AppLanguagePreference>(
      AppLanguageController.new,
    );

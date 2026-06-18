import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _storageKey = 'app_language';

  @override
  Future<AppLanguagePreference> build() async {
    final preferences = await SharedPreferences.getInstance();
    return _fromStorage(preferences.getString(_storageKey));
  }

  Future<void> setPreference(AppLanguagePreference preference) async {
    state = AsyncData(preference);
    final preferences = await SharedPreferences.getInstance();
    if (preference == AppLanguagePreference.system) {
      await preferences.remove(_storageKey);
    } else {
      await preferences.setString(_storageKey, preference.storageValue);
    }
  }

  AppLanguagePreference _fromStorage(String? value) => switch (value) {
    'es' => AppLanguagePreference.spanish,
    'en' => AppLanguagePreference.english,
    _ => AppLanguagePreference.system,
  };
}

final appLanguageProvider =
    AsyncNotifierProvider<AppLanguageController, AppLanguagePreference>(
      AppLanguageController.new,
    );

import 'package:backlog_vault/features/settings/application/app_language.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses system language by default and persists a device override', () async {
    final firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);

    expect(
      await firstContainer.read(appLanguageProvider.future),
      AppLanguagePreference.system,
    );

    await firstContainer
        .read(appLanguageProvider.notifier)
        .setPreference(AppLanguagePreference.english);

    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);
    expect(
      await secondContainer.read(appLanguageProvider.future),
      AppLanguagePreference.english,
    );
  });

  test('system selection removes the persisted override', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'es'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      await container.read(appLanguageProvider.future),
      AppLanguagePreference.spanish,
    );

    await container
        .read(appLanguageProvider.notifier)
        .setPreference(AppLanguagePreference.system);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('app_language'), isFalse);
  });
}

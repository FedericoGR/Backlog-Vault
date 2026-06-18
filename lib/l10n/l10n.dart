import 'package:flutter/widgets.dart';

import 'app_localizations.dart';
import 'app_localizations_es.dart';

export 'app_localizations.dart';

final _spanishFallback = AppLocalizationsEs();

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      _spanishFallback;
}

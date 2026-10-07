import 'package:flutter/widgets.dart';

import 'app_localization.dart';
import 'app_strings.dart';

extension LocalizationContext on BuildContext {
  /// Convenient accessor for localized strings in widgets
  AppStrings get loc => AppLocalization.of(this)?.strings ?? AppLocalization.current;
}

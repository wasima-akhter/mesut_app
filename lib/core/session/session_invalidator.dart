import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/entry/nav/navigation_provider.dart';

/// Centralized session state cleanup across user-scoped Riverpod providers.
void clearUserSessionState(Ref ref) {
  debugPrint(
    'clearUserSessionState: Resetting navigation and user-scoped providers...',
  );

  try {
    ref.invalidate(navigationProvider);
  } catch (e) {
    debugPrint('Error invalidating navigationProvider: $e');
  }
}


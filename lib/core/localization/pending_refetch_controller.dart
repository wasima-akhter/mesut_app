import 'dart:async';

import 'package:flutter/material.dart';

import 'app_localization.dart';
import 'localization_meta.dart';
import 'localization_provider.dart';

/// Returns true if any item in [metas] has `PENDING` or `PROCESSING` status.
bool anyLocalizationPending(Iterable<LocalizationMeta?> metas) =>
    metas.any((m) => m?.isPending == true);

/// Exposes whether [PendingPollEffect] timed out waiting for a backend
/// translation so [TranslationStatusBadge] can fall back from an infinite
/// spinner to a calm "Original" indicator.
class TranslationTimeoutScope extends InheritedWidget {
  const TranslationTimeoutScope({
    super.key,
    required this.isTimedOut,
    required super.child,
  });

  final bool isTimedOut;

  static bool isTimedOutOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<TranslationTimeoutScope>()
            ?.isTimedOut ??
        false;
  }

  @override
  bool updateShouldNotify(TranslationTimeoutScope oldWidget) =>
      isTimedOut != oldWidget.isTimedOut;
}

/// Non-blocking periodic poller for screens displaying items with
/// `PENDING` or `PROCESSING` backend translations (Guide Section 10).
///
/// Always stops automatically when no items remain pending or on [dispose].
/// When [maxPolls] consecutive polls complete without resolution, marks itself
/// timed out and invokes [onTimeout] once.
class PendingRefetchController {
  Timer? _timer;
  int _consecutivePolls = 0;
  bool _timedOut = false;
  VoidCallback? _currentRefetch;
  VoidCallback? _currentTimeout;

  static const int maxConsecutivePolls = 15;

  bool get isTimedOut => _timedOut;

  void resetTimeout() {
    _timedOut = false;
  }

  void sync({
    required bool hasPending,
    required VoidCallback refetch,
    Duration interval = const Duration(seconds: 3),
    int maxPolls = maxConsecutivePolls,
    VoidCallback? onTimeout,
  }) {
    _currentRefetch = refetch;
    _currentTimeout = onTimeout;
    debugPrint(
      '[TranslationPoll] sync: hasPending=$hasPending, activeLang=${AppLanguageNotifier.activeLanguageCode}',
    );

    if (!hasPending) {
      if (_timer != null) {
        debugPrint(
          '[TranslationPoll] All translations ready in selected language (${AppLanguageNotifier.activeLanguageCode}). Polling stopped.',
        );
      }
      _timedOut = false;
      cancel();
      return;
    }

    if (_timedOut) return;
    if (_timer != null) {
      // Poller is already active and ticking; callbacks are refreshed.
      return;
    }

    _consecutivePolls = 0;
    debugPrint(
      '[TranslationPoll] Started progressive backoff polling for pending translations (active language: ${AppLanguageNotifier.activeLanguageCode}, base: ${interval.inSeconds}s, maxPolls: $maxPolls)...',
    );
    _scheduleNextPoll(baseInterval: interval, maxPolls: maxPolls);
  }

  void _scheduleNextPoll({
    required Duration baseInterval,
    required int maxPolls,
  }) {
    if (_consecutivePolls >= maxPolls) {
      debugPrint(
        '[TranslationPoll] Max polls reached ($maxPolls). Polling timed out.',
      );
      _timedOut = true;
      cancel();
      _currentTimeout?.call();
      return;
    }

    // Progressive backoff: base (e.g. 2s/3s) -> 4s -> 8s -> 16s -> capped at 30s
    final shift = _consecutivePolls > 4 ? 4 : _consecutivePolls;
    final delaySec =
        (baseInterval.inSeconds * (1 << shift)).clamp(baseInterval.inSeconds, 30);
    final delay = Duration(seconds: delaySec);

    _timer = Timer(delay, () {
      _consecutivePolls++;
      debugPrint(
        '[TranslationPoll] Poll tick $_consecutivePolls/$maxPolls (delay: ${delaySec}s) - refetching data in selected language (${AppLanguageNotifier.activeLanguageCode})...',
      );
      _currentRefetch?.call();
      _scheduleNextPoll(baseInterval: baseInterval, maxPolls: maxPolls);
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _consecutivePolls = 0;
  }

  void dispose() {
    cancel();
    _currentRefetch = null;
    _currentTimeout = null;
  }
}

/// Lifecycle-aware widget wrapper that polls [onPoll] periodically while
/// [hasPending] is `true` and this screen widget stays mounted.
///
/// If polling exhausts [maxPolls] without translation completing, it falls back
/// to showing original content, updates [TranslationTimeoutScope], and notifies
/// the user with a non-blocking SnackBar (with a Retry action).
class PendingPollEffect extends StatefulWidget {
  const PendingPollEffect({
    super.key,
    required this.hasPending,
    required this.onPoll,
    required this.child,
    this.interval = const Duration(seconds: 3),
    this.maxPolls = PendingRefetchController.maxConsecutivePolls,
    this.onTimeout,
  });

  final bool hasPending;
  final VoidCallback onPoll;
  final Widget child;
  final Duration interval;
  final int maxPolls;
  final VoidCallback? onTimeout;

  @override
  State<PendingPollEffect> createState() => _PendingPollEffectState();
}

class _PendingPollEffectState extends State<PendingPollEffect> {
  final PendingRefetchController _poller = PendingRefetchController();
  bool _hasTimedOut = false;
  bool _notifiedTimeout = false;

  @override
  void initState() {
    super.initState();
    _syncPoller();
  }

  @override
  void didUpdateWidget(covariant PendingPollEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.hasPending && (_hasTimedOut || _notifiedTimeout)) {
      _hasTimedOut = false;
      _notifiedTimeout = false;
      _poller.resetTimeout();
    }
    _syncPoller();
  }

  void _syncPoller() {
    _poller.sync(
      hasPending: widget.hasPending,
      refetch: widget.onPoll,
      interval: widget.interval,
      maxPolls: widget.maxPolls,
      onTimeout: _handleTimeout,
    );
  }

  void _handleTimeout() {
    if (!mounted) return;
    setState(() {
      _hasTimedOut = true;
    });
    widget.onTimeout?.call();

    if (_notifiedTimeout) return;
    _notifiedTimeout = true;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final message = AppLocalization.current.translationTakingLonger;
    final retryLabel = AppLocalization.current.retry;
    final dismissLabel = AppLocalization.current.dismiss;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    foregroundColor: Colors.white70,
                  ),
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                  },
                  child: Text(dismissLabel),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    foregroundColor: const Color(0xFFFFB74D),
                  ),
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    _retryPolling();
                  },
                  child: Text(
                    retryLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        showCloseIcon: true,
        closeIconColor: Colors.white70,
      ),
    );
  }

  void _retryPolling() {
    if (!mounted) return;
    setState(() {
      _hasTimedOut = false;
      _notifiedTimeout = false;
    });
    _poller.resetTimeout();
    widget.onPoll();
    _syncPoller();
  }

  @override
  void dispose() {
    _poller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TranslationTimeoutScope(
      isTimedOut: _hasTimedOut,
      child: widget.child,
    );
  }
}

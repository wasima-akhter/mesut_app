import 'dart:async';

import 'package:flutter/material.dart';

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
    if (!hasPending) {
      _timedOut = false;
      cancel();
      return;
    }

    if (_timedOut || _timer != null) return;
    _consecutivePolls = 0;
    _timer = Timer.periodic(interval, (_) {
      if (_consecutivePolls >= maxPolls) {
        _timedOut = true;
        cancel();
        onTimeout?.call();
        return;
      }
      _consecutivePolls++;
      refetch();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _consecutivePolls = 0;
  }

  void dispose() {
    cancel();
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
    if (oldWidget.hasPending != widget.hasPending ||
        oldWidget.interval != widget.interval ||
        oldWidget.maxPolls != widget.maxPolls) {
      _syncPoller();
    }
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

    final isDe = AppLanguageNotifier.activeLanguageCode.toLowerCase() == 'de';
    final message = isDe
        ? 'Die Übersetzung dauert länger als erwartet. Ursprünglicher Inhalt wird angezeigt.'
        : 'Translation is taking longer than expected. Showing original content.';
    final retryLabel = isDe ? 'Wiederholen' : 'Retry';

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: retryLabel,
          onPressed: _retryPolling,
        ),
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

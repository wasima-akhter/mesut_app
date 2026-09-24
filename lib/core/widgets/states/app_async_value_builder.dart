import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../loading/app_loader.dart';
import 'app_error_state.dart';

class AppAsyncValueBuilder<T> extends StatelessWidget {
  const AppAsyncValueBuilder({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final Widget? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const Center(child: AppLoader()),
      error: (err, stack) =>
          error?.call(err, stack) ??
          AppErrorState(message: err.toString(), onRetry: () {}),
    );
  }
}

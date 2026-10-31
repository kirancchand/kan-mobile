import 'package:flutter/material.dart';

import 'error_state.dart';
import 'shimmer_list_placeholder.dart';

/// Thin wrapper around FutureBuilder that standardizes the loading / error /
/// data states so screens don't repeat the same boilerplate.
class AsyncView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  const AsyncView(
      {super.key, required this.future, required this.builder, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorState(onRetry: onRetry);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerListPlaceholder();
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

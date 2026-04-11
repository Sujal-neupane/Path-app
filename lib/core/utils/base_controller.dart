import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base controller to handle common logic for features using the newer Notifier API
/// Extend this to use in Presentation layer (Features)
abstract class BaseController<T> extends Notifier<AsyncValue<T>> {
  @override
  AsyncValue<T> build() => const AsyncValue.loading();

  /// Helper to handle long running tasks with loading and error states
  Future<void> executeTask(Future<T> Function() task) async {
    state = const AsyncValue.loading();
    try {
      final result = await task();
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reset state to initial data if needed
  void updateData(T data) {
    state = AsyncValue.data(data);
  }
}


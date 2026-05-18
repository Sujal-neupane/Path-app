import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/storage/onboarding_storage_service.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_session_controller.dart';

final splashDestinationProvider = FutureProvider<String>((ref) async {
  final onboardingService = ref.read(onboardingStorageServiceProvider);
  final hasSeenOnboarding = onboardingService.isCompleted();

  if (!hasSeenOnboarding) {
    return '/onboarding';
  }

  try {
    final session = await ref.read(authSessionControllerProvider.future);
    return session.isAuthenticated ? '/dashboard' : '/login';
  } catch (_) {
    return '/login';
  }
});

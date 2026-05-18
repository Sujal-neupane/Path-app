import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/auth/data/repositories/auth_repository.dart';
import 'package:path_app/features/auth/presentation/state/auth_session_state.dart';

final authSessionControllerProvider =
    AsyncNotifierProvider<AuthSessionController, AuthSessionState>(
      AuthSessionController.new,
    );

class AuthSessionController extends AsyncNotifier<AuthSessionState> {
  @override
  Future<AuthSessionState> build() async {
    return _resolveSession();
  }

  Future<AuthSessionState> restoreSession() async {
    final resolved = await _resolveSession();
    state = AsyncData(resolved);
    return resolved;
  }

  Future<void> refreshSession() async {
    state = const AsyncLoading();
    state = AsyncData(await _resolveSession());
  }

  Future<void> signOut() async {
    final repository = await ref.read(authRepositoryProvider.future);
    await repository.logout();
    state = const AsyncData(AuthSessionState.unauthenticated());
  }

  Future<AuthSessionState> _resolveSession() async {
    final repository = await ref.read(authRepositoryProvider.future);
    final isLoggedIn = await repository.isLoggedIn();
    if (!isLoggedIn) {
      return const AuthSessionState.unauthenticated();
    }

    try {
      final currentUser = await repository.getCurrentUser();
      if (currentUser == null) {
        await repository.logout();
        return const AuthSessionState.unauthenticated();
      }
      return AuthSessionState.authenticated(currentUser);
    } catch (_) {
      await repository.logout();
      return const AuthSessionState.unauthenticated();
    }
  }
}

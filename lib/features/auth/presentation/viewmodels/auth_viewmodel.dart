import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/auth/data/repositories/auth_repository.dart';
import 'package:path_app/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthInitial();
  }

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final repository = await ref.read(authRepositoryProvider.future);
      await repository.login(email, password);
      state = AuthSuccess();
    } catch (e) {
      state = AuthError('The trail is blocked: ${e.toString()}');
    }
  }

  Future<void> register(String fullName, String email, String phone, String password) async {
    state = AuthLoading();
    try {
      final repository = await ref.read(authRepositoryProvider.future);
      await repository.register(
        fullname: fullName,
        email: email,
        phonenumber: phone,
        password: password,
      );
      state = AuthSuccess();
    } catch (e) {
      state = AuthError('Could not pack your gears: ${e.toString()}');
    }
  }
}

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

  // ── Form State Helpers ──

  AuthFormState get _formState {
    if (state is AuthFormState) return state as AuthFormState;
    return const AuthFormState();
  }

  /// Initialize form state (call when entering login/register screens).
  void initForm({int registerStep = 0}) {
    state = AuthFormState(registerStep: registerStep);
  }

  /// Validate a single field and update errors map.
  void validateField(String fieldName, String value) {
    final errors = Map<String, String?>.from(_formState.fieldErrors);
    errors[fieldName] = _getFieldError(fieldName, value);

    double strength = _formState.passwordStrength;
    if (fieldName == 'password') {
      strength = _calculatePasswordStrength(value);
    }

    state = _formState.copyWith(
      fieldErrors: errors,
      passwordStrength: strength,
    );
  }

  /// Check if a specific field has a validation error.
  String? getFieldError(String fieldName) {
    if (state is AuthFormState) {
      return (state as AuthFormState).fieldErrors[fieldName];
    }
    return null;
  }

  /// Navigate to the next register wizard step.
  bool nextRegisterStep() {
    final form = _formState;
    if (form.registerStep < 1) {
      state = form.copyWith(registerStep: form.registerStep + 1);
      return true;
    }
    return false;
  }

  /// Navigate to the previous register wizard step.
  bool prevRegisterStep() {
    final form = _formState;
    if (form.registerStep > 0) {
      state = form.copyWith(registerStep: form.registerStep - 1);
      return true;
    }
    return false;
  }

  /// Reset to initial state.
  void resetState() {
    state = AuthInitial();
  }

  // ── Core Auth Actions ──

  Future<void> login(String email, String password) async {
    // Validate before submitting
    final emailError = _getFieldError('email', email);
    final passError = _getFieldError('password', password);

    if (emailError != null || passError != null) {
      state = AuthFormState(
        fieldErrors: {'email': emailError, 'password': passError},
      );
      return;
    }

    state = AuthLoading();
    try {
      final repository = await ref.read(authRepositoryProvider.future);
      await repository.login(email, password);
      state = AuthSuccess();
    } catch (e) {
      state = AuthError(_extractUserMessage(e, 'Login failed. Please try again.'));
    }
  }

  Future<void> register(
      String fullName, String email, String phone, String password) async {
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
      state = AuthError(_extractUserMessage(e, 'Registration failed. Please try again.'));
    }
  }

  // ── Private Validation Logic ──

  String? _getFieldError(String fieldName, String value) {
    if (value.trim().isEmpty) {
      return _emptyFieldMessage(fieldName);
    }

    switch (fieldName) {
      case 'email':
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Invalid email address';
        }
        break;
      case 'password':
        if (value.length < 6) {
          return 'Password too short (min 6 characters)';
        }
        break;
      case 'fullName':
        if (value.trim().length < 2) {
          return 'Name too short';
        }
        break;
      case 'phoneNumber':
        if (value.trim().length < 7) {
          return 'Invalid phone number';
        }
        break;
    }
    return null;
  }

  String _emptyFieldMessage(String fieldName) {
    switch (fieldName) {
      case 'email':
        return 'Email is required';
      case 'password':
        return 'Password is required';
      case 'name':
        return 'Name is required';
      case 'phone':
        return 'Phone number is required';
      default:
        return 'This field is required';
    }
  }

  /// Extracts a user-friendly error message from an exception.
  /// Avoids leaking stack traces to the UI.
  String _extractUserMessage(Object error, String fallback) {
    final raw = error.toString();

    // Check for common network/auth error keywords
    if (raw.contains('SocketException') || raw.contains('Connection')) {
      return 'No internet connection. Please check your network.';
    }
    if (raw.contains('401') || raw.contains('Unauthorized')) {
      return 'Invalid credentials. Please try again.';
    }
    if (raw.contains('409') || raw.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('timeout') || raw.contains('Timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (raw.contains('Null check') || raw.contains('null value')) {
      return fallback;
    }

    // If it's a short message (no stack trace), use it
    if (raw.length < 100 && !raw.contains('#0')) {
      return raw;
    }

    return fallback;
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;
    strength += (password.length / 20).clamp(0.0, 0.3);
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.1;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      strength += 0.25;
    }

    return strength.clamp(0.0, 1.0);
  }
}

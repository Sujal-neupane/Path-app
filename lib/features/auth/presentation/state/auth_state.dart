import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Tracks field-level validation and multi-step register progress.
class AuthFormState extends AuthState {
  /// Per-field error messages. Key = field name, value = error message (null = valid).
  final Map<String, String?> fieldErrors;

  /// Current step in the register wizard (0-indexed). 0 = step 1, 1 = step 2.
  final int registerStep;

  /// Password strength score (0.0 – 1.0) for the altitude meter.
  final double passwordStrength;

  const AuthFormState({
    this.fieldErrors = const {},
    this.registerStep = 0,
    this.passwordStrength = 0.0,
  });

  AuthFormState copyWith({
    Map<String, String?>? fieldErrors,
    int? registerStep,
    double? passwordStrength,
  }) {
    return AuthFormState(
      fieldErrors: fieldErrors ?? this.fieldErrors,
      registerStep: registerStep ?? this.registerStep,
      passwordStrength: passwordStrength ?? this.passwordStrength,
    );
  }

  @override
  List<Object?> get props => [fieldErrors, registerStep, passwordStrength];
}

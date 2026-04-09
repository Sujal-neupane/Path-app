import 'package:equatable/equatable.dart';

 class User extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String? phoneNumber;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
  });


  @override
  List<Object?> get props => [id, name, email, phoneNumber];

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
 }
// the User entity represents the core user data structure in the authentication domain. It includes essential fields like id, name, and email, and extends Equatable for value comparison. The copyWith method allows for easy creation of modified user instances while maintaining immutability.

  // Add this inside lib/features/auth/domain/entities/user.dart

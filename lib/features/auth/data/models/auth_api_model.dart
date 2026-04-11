
import 'package:path_app/features/auth/domain/entities/user.dart';

class AuthApiModel {
  final String? id;
  final String email;
  final String fullName;
  final String password;
  final String phoneNumber;

  AuthApiModel({
    this.id,
    required this.email,
    required this.fullName,
    required this.password,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'password': password,
      'phoneNumber': phoneNumber,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? json['name'] as String? ?? '',
      password: json['password'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String? ?? '',
    );
  }

  User toEntity() {
    return User(
      id: '', // ID will be assigned by the backend
      name: fullName,
      email: email,
      phoneNumber: phoneNumber,
     );
   }

   factory AuthApiModel.fromEntity(User user, {String password = ''}) {
     return AuthApiModel(
       email: user.email,
       fullName: user.name,
       password: password,
       phoneNumber: user.phoneNumber ?? '',
     );
   }

   static List<User> toEntityList(List<AuthApiModel> apiModels) {
     return apiModels.map((model) => model.toEntity()).toList();
   }

}
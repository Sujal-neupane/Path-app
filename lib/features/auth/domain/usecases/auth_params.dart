import 'package:equatable/equatable.dart';

class LoginParams extends Equatable{
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}


class RegisterParams extends Equatable{
  final String fullname;
  final String email;
  final String password;
  final String phonenumber;

  const RegisterParams({
    required this.fullname,
    required this.email,
    required this.password,
    required this.phonenumber
  });

  @override
  List<Object?> get props => [fullname, email, password, phonenumber];
}


// the auth params for usecases are for the login and register usecases, they are used to pass the parameters from the presentation layer to the domain layer. They are also used to validate the parameters before passing them to the repository.
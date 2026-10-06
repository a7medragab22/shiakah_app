part of "../../auth.dart";

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String email;
  final String? userName;
  final String password;

  const RegisterSubmitted({
    required this.email,
    this.userName,
    required this.password,
  });

  @override
  List<Object?> get props => [email, userName, password];
}
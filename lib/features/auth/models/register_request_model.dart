import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class RegisterRequestModel extends Equatable {
  final String email;
  final String? userName;
  final String password;

  const RegisterRequestModel({
    required this.email,
    this.userName,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'Email': email,
      'UserName': userName ?? (email.contains('@') ? email.split('@').first : email),
      'Password': password,
    };
  }

  FormData toFormData() {
    return FormData.fromMap(toMap());
  }

  RegisterRequestModel copyWith({
    String? email,
    String? userName,
    String? password,
  }) {
    return RegisterRequestModel(
      email: email ?? this.email,
      userName: userName ?? this.userName,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [email, userName, password];
}

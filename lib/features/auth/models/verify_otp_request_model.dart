import 'package:equatable/equatable.dart';

class VerifyOtpRequestModel extends Equatable {
  final String email;
  final String otp;

  const VerifyOtpRequestModel({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  @override
  List<Object?> get props => [email, otp];
}

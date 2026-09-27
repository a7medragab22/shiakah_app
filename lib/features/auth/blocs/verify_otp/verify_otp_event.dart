part of "../../auth.dart";

abstract class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();

  @override
  List<Object?> get props => [];
}

class VerifyOtpSubmitted extends VerifyOtpEvent {
  final String email;
  final String otp;

  const VerifyOtpSubmitted({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

class ResendOtpSubmitted extends VerifyOtpEvent {
  final String email;

  const ResendOtpSubmitted({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

part of "../../auth.dart";
abstract class LogoutEvent extends Equatable {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

class LogoutSubmitted extends LogoutEvent {
  final String? refreshToken;
  const LogoutSubmitted({this.refreshToken});

  @override
  List<Object?> get props => [refreshToken];
}
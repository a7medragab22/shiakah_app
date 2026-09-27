part of "../../auth.dart";

abstract class GenderEvent extends Equatable {
  const GenderEvent();

  @override
  List<Object?> get props => [];
}

class GenderSubmitted extends GenderEvent {
  final int gender;

  const GenderSubmitted({
    required this.gender,
  });

  @override
  List<Object?> get props => [gender];
}

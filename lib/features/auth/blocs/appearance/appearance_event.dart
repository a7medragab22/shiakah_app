part of "../../auth.dart";

abstract class AppearanceEvent extends Equatable {
  const AppearanceEvent();

  @override
  List<Object?> get props => [];
}

class AppearanceSubmitted extends AppearanceEvent {
  final int ageRange;
  final int skinTone;

  const AppearanceSubmitted({
    required this.ageRange,
    required this.skinTone,
  });

  @override
  List<Object?> get props => [ageRange, skinTone];
}

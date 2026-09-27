part of "../../auth.dart";

abstract class OnboardingProfileEvent extends Equatable {
  const OnboardingProfileEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingProfileSubmitted extends OnboardingProfileEvent {
  final String name;
  final String location;

  const OnboardingProfileSubmitted({
    required this.name,
    required this.location,
  });

  @override
  List<Object?> get props => [name, location];
}

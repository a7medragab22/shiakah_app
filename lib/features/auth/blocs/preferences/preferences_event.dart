part of "../../auth.dart";

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object?> get props => [];
}

class PreferencesSubmitted extends PreferencesEvent {
  final List<int> styles;
  final List<int> preferredColors;

  const PreferencesSubmitted({
    required this.styles,
    required this.preferredColors,
  });

  @override
  List<Object?> get props => [styles, preferredColors];
}

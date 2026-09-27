part of "../../auth.dart";

abstract class BodyEvent extends Equatable {
  const BodyEvent();

  @override
  List<Object?> get props => [];
}

class BodySubmitted extends BodyEvent {
  final double height;
  final double weight;
  final int bodyType;

  const BodySubmitted({
    required this.height,
    required this.weight,
    required this.bodyType,
  });

  @override
  List<Object?> get props => [height, weight, bodyType];
}

import 'package:equatable/equatable.dart';

enum BodyType {
  slim(1),
  regular(2),
  athletic(3),
  stocky(4),
  plusSized(5);

  final int value;
  const BodyType(this.value);

  static BodyType fromValue(int value) {
    return BodyType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BodyType.regular,
    );
  }

  static BodyType fromString(String id) {
    switch (id.toLowerCase().replaceAll(' ', '_')) {
      case 'slim':
        return BodyType.slim;
      case 'regular':
        return BodyType.regular;
      case 'athletic':
        return BodyType.athletic;
      case 'stocky':
        return BodyType.stocky;
      case 'plus_size':
      case 'plus_sized':
      case 'plussize':
      case 'plussized':
        return BodyType.plusSized;
      default:
        return BodyType.slim;
    }
  }
}

class BodyRequestModel extends Equatable {
  final double height;
  final double weight;
  final int bodyType;

  const BodyRequestModel({
    required this.height,
    required this.weight,
    required this.bodyType,
  });

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'bodyType': bodyType,
      };

  factory BodyRequestModel.fromJson(Map<String, dynamic> json) =>
      BodyRequestModel(
        height: (json['height'] as num).toDouble(),
        weight: (json['weight'] as num).toDouble(),
        bodyType: json['bodyType'] as int,
      );

  @override
  List<Object?> get props => [height, weight, bodyType];
}

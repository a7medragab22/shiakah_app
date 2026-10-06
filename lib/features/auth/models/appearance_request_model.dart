import 'package:equatable/equatable.dart';

enum SkinTone {
  veryLight(1),
  light(2),
  medium(3),
  tan(4),
  brown(5),
  dark(6);

  final int value;
  const SkinTone(this.value);

  static SkinTone fromValue(int value) {
    return SkinTone.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SkinTone.veryLight,
    );
  }
}

enum AgeRange {
  from1To17(1),
  from18To24(2),
  from25To34(3),
  from35To44(4),
  from45AndAbove(5);

  final int value;
  const AgeRange(this.value);

  static AgeRange fromValue(int value) {
    return AgeRange.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AgeRange.from1To17,
    );
  }
}

class AppearanceRequestModel extends Equatable {
  final int ageRange;
  final int skinTone;

  const AppearanceRequestModel({
    required this.ageRange,
    required this.skinTone,
  });

  Map<String, dynamic> toJson() => {
        'ageRange': ageRange,
        'skinTone': skinTone,
      };

  factory AppearanceRequestModel.fromJson(Map<String, dynamic> json) =>
      AppearanceRequestModel(
        ageRange: json['ageRange'] as int,
        skinTone: json['skinTone'] as int,
      );

  @override
  List<Object?> get props => [ageRange, skinTone];
}

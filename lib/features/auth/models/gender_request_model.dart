import 'package:equatable/equatable.dart';

class GenderRequestModel extends Equatable {
  final int gender;

  const GenderRequestModel({required this.gender});

  Map<String, dynamic> toJson() => {
        'gender': gender,
      };

  factory GenderRequestModel.fromJson(Map<String, dynamic> json) =>
      GenderRequestModel(gender: json['gender'] as int);

  @override
  List<Object?> get props => [gender];
}

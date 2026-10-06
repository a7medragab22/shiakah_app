import 'package:equatable/equatable.dart';

class OnboardingProfileRequestModel extends Equatable {
  final String name;
  final String location;

  const OnboardingProfileRequestModel({
    required this.name,
    required this.location,
  });

  factory OnboardingProfileRequestModel.fromJson(Map<String, dynamic> json) {
    return OnboardingProfileRequestModel(
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
    };
  }

  OnboardingProfileRequestModel copyWith({
    String? name,
    String? location,
  }) {
    return OnboardingProfileRequestModel(
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [name, location];
}

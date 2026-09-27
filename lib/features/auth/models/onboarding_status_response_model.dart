import 'package:equatable/equatable.dart';
import '../../../../core/router/router.dart';

class OnboardingStatusResponseModel extends Equatable {
  final bool? success;
  final OnboardingStatusData? data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const OnboardingStatusResponseModel({
    this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory OnboardingStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusResponseModel(
      success: json['success'] as bool?,
      data: json['data'] != null
          ? OnboardingStatusData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      errors: json['errors'],
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'errors': errors,
      'meta': meta,
    };
  }

  @override
  List<Object?> get props => [success, data, message, errors, meta];
}

class OnboardingStatusData extends Equatable {
  final int currentStep;
  final bool completed;
  final OnboardingProfileData? profile;

  const OnboardingStatusData({
    this.currentStep = 1,
    this.completed = false,
    this.profile,
  });

  factory OnboardingStatusData.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusData(
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 1,
      completed: json['completed'] as bool? ?? false,
      profile: json['profile'] != null
          ? OnboardingProfileData.fromJson(
              json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'completed': completed,
      'profile': profile?.toJson(),
    };
  }

  /// Maps the current onboarding status to the corresponding App Route.
  String get targetRoute {
    if (completed || currentStep >= 6) {
      return Routes.home;
    }

    switch (currentStep) {
      case 1:
        return Routes.genderSelection;
      case 2:
        return Routes.personalInfo;
      case 3:
        return Routes.bodyType;
      case 4:
        return Routes.defineStyle;
      case 5:
        return Routes.completeProfile;
      default:
        return Routes.genderSelection;
    }
  }

  @override
  List<Object?> get props => [currentStep, completed, profile];
}

class OnboardingProfileData extends Equatable {
  final String? gender;
  final String? ageRange;
  final String? skinTone;
  final double? height;
  final double? weight;
  final String? bodyType;
  final String? name;
  final String? location;

  const OnboardingProfileData({
    this.gender,
    this.ageRange,
    this.skinTone,
    this.height,
    this.weight,
    this.bodyType,
    this.name,
    this.location,
  });

  factory OnboardingProfileData.fromJson(Map<String, dynamic> json) {
    return OnboardingProfileData(
      gender: json['gender']?.toString(),
      ageRange: json['ageRange']?.toString(),
      skinTone: json['skinTone']?.toString(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyType: json['bodyType']?.toString(),
      name: json['name']?.toString(),
      location: json['location']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'ageRange': ageRange,
      'skinTone': skinTone,
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
      'name': name,
      'location': location,
    };
  }

  @override
  List<Object?> get props => [
        gender,
        ageRange,
        skinTone,
        height,
        weight,
        bodyType,
        name,
        location,
      ];
}

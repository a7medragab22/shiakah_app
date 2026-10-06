import 'package:equatable/equatable.dart';
import '../../../../database/models/item_attributes.dart';

sealed class WardrobeScannerState extends Equatable {
  const WardrobeScannerState();

  @override
  List<Object?> get props => [];
}

/// Initial resting state before an image is scanned.
class WardrobeScannerInitial extends WardrobeScannerState {
  const WardrobeScannerInitial();
}

/// Active preprocessing and TFLite neural inference.
class WardrobeScannerLoading extends WardrobeScannerState {
  final String message;

  const WardrobeScannerLoading({
    this.message = 'Analyzing clothing item...',
  });

  @override
  List<Object?> get props => [message];
}

/// Scan succeeded with high-confidence detected attributes.
class WardrobeScannerSuccess extends WardrobeScannerState {
  final ItemAttributes attributes;
  final String imagePath;

  const WardrobeScannerSuccess({
    required this.attributes,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [attributes, imagePath];
}

/// Scan succeeded, but one or more attributes fell below confidence threshold (isLowConfidence).
class WardrobeScannerLowConfidence extends WardrobeScannerState {
  final ItemAttributes attributes;
  final String imagePath;
  final String userNotice;

  const WardrobeScannerLowConfidence({
    required this.attributes,
    required this.imagePath,
    this.userNotice =
        'Could not clearly detect clothing item, please retake or pick another photo.',
  });

  @override
  List<Object?> get props => [attributes, imagePath, userNotice];
}

/// Inference or preprocessing failed.
class WardrobeScannerFailure extends WardrobeScannerState {
  final String errorMessage;

  const WardrobeScannerFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

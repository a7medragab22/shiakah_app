import 'dart:io';
import 'package:equatable/equatable.dart';

sealed class WardrobeScannerEvent extends Equatable {
  const WardrobeScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers image preprocessing and MobileCLIP scanning on [imageFile].
class ScanWardrobeImageRequested extends WardrobeScannerEvent {
  final File imageFile;

  const ScanWardrobeImageRequested({required this.imageFile});

  @override
  List<Object?> get props => [imageFile.path];
}

/// Resets the scanner state back to [WardrobeScannerInitial].
class ResetWardrobeScan extends WardrobeScannerEvent {
  const ResetWardrobeScan();
}

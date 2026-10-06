import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/service_locator/scanner/scanner.dart';
import 'wardrobe_scanner_event.dart';
import 'wardrobe_scanner_state.dart';

export 'wardrobe_scanner_event.dart';
export 'wardrobe_scanner_state.dart';

class WardrobeScannerBloc
    extends Bloc<WardrobeScannerEvent, WardrobeScannerState> {
  ScannerService? _scannerService;

  WardrobeScannerBloc({ScannerService? scannerService})
      : _scannerService = scannerService,
        super(const WardrobeScannerInitial()) {
    on<ScanWardrobeImageRequested>(_onScanRequested);
    on<ResetWardrobeScan>(_onReset);
  }

  Future<ScannerService> _resolveService() async {
    if (_scannerService != null) return _scannerService!;
    if (GetIt.instance.isRegistered<ScannerService>() &&
        GetIt.instance.isReadySync<ScannerService>()) {
      _scannerService = GetIt.instance<ScannerService>();
      return _scannerService!;
    }
    _scannerService = await GetIt.instance.getAsync<ScannerService>();
    return _scannerService!;
  }

  Future<void> _onScanRequested(
    ScanWardrobeImageRequested event,
    Emitter<WardrobeScannerState> emit,
  ) async {
    emit(const WardrobeScannerLoading());

    try {
      debugPrint('[SCANNER_BLOC] Starting scan for path: ${event.imageFile.path}');
      Uint8List bytes;
      if (event.imageFile.path.startsWith('assets/')) {
        final byteData = await rootBundle.load(event.imageFile.path);
        bytes = byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      } else {
        if (!await event.imageFile.exists()) {
          debugPrint('[SCANNER_BLOC] Error: Image file does not exist at ${event.imageFile.path}');
          emit(
            const WardrobeScannerFailure(
              errorMessage: 'Image file does not exist or could not be read.',
            ),
          );
          return;
        }
        bytes = await event.imageFile.readAsBytes();
      }

      debugPrint('[SCANNER_BLOC] Image bytes loaded: ${bytes.length} bytes. Resolving ScannerService...');
      final service = await _resolveService();
      debugPrint('[SCANNER_BLOC] ScannerService resolved. Running scanWardrobeBytes...');
      final attributes = await service.scanWardrobeBytes(bytes);

      debugPrint('[SCANNER_BLOC] Scan successful! Result: '
          'category=${attributes.category} (${attributes.confidenceOf('category')}), '
          'subcategory=${attributes.subcategory} (${attributes.confidenceOf('subcategory')}), '
          'style=${attributes.style} (${attributes.confidenceOf('style')}), '
          'season=${attributes.season} (${attributes.confidenceOf('season')}), '
          'color=${attributes.dominantColor} (${attributes.confidenceOf('dominantColor')}), '
          'isLowConfidence=${attributes.isLowConfidence}, '
          'isValidClothing=${attributes.isValidClothing}');

      if (!attributes.isValidClothing) {
        debugPrint('[SCANNER_BLOC] Not valid clothing (isValidClothing == false). Emitting WardrobeScannerFailure.');
        emit(
          WardrobeScannerFailure(
            errorMessage: 'No valid clothing item detected.',
          ),
        );
      } else if (attributes.isLowConfidence) {
        debugPrint('[SCANNER_BLOC] Valid clothing, but low confidence on some secondary fields.');
        emit(
          WardrobeScannerLowConfidence(
            attributes: attributes,
            imagePath: event.imageFile.path,
          ),
        );
      } else {
        debugPrint('[SCANNER_BLOC] Scan confident & success! Emitting WardrobeScannerSuccess.');
        emit(
          WardrobeScannerSuccess(
            attributes: attributes,
            imagePath: event.imageFile.path,
          ),
        );
      }
    } catch (e, stack) {
      debugPrint('[SCANNER_BLOC] EXCEPTION in scan: $e\n$stack');
      emit(
        WardrobeScannerFailure(
          errorMessage: 'Scan failed: ${e.toString()}',
        ),
      );
    }
  }

  void _onReset(
    ResetWardrobeScan event,
    Emitter<WardrobeScannerState> emit,
  ) {
    emit(const WardrobeScannerInitial());
  }
}

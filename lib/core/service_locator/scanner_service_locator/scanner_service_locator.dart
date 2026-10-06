part of '../service_locator.dart';

class ScannerServiceLocator {
  static Future<void> execute({required GetIt getIt}) async {
    if (!getIt.isRegistered<ClipScanner>()) {
      getIt.registerLazySingletonAsync<ClipScanner>(() => ClipScanner.load());
    }

    if (!getIt.isRegistered<ScannerService>()) {
      getIt.registerLazySingletonAsync<ScannerService>(() async {
        final scanner = await getIt.getAsync<ClipScanner>();
        return ScannerService.forScanner(scanner);
      });
    }

    if (!getIt.isRegistered<WardrobeScannerBloc>()) {
      getIt.registerFactory<WardrobeScannerBloc>(() => WardrobeScannerBloc());
    }
  }

  /// Triggers safe warmup of the scanner service and zero-shot classifier prompts.
  static Future<void> warmup({required GetIt getIt}) async {
    try {
      final scanner = await getIt.getAsync<ClipScanner>();
      scanner.warmUp();
      final service = await getIt.getAsync<ScannerService>();
      service.warmUp();
    } catch (e) {
      debugPrint('Scanner warmup skipped or failed: $e');
    }
  }
}

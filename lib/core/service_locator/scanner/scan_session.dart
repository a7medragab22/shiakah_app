import 'package:shiakah/core/service_locator/scanner/color_analyzer.dart';
import 'package:shiakah/core/service_locator/scanner/scanner_service.dart';
import 'package:shiakah/database/models/attribute_source.dart';
import 'package:shiakah/database/models/item_attributes.dart';

/// A single scan awaiting the user's confirmation (T-SCAN-06).
///
/// This is the contract Chat 5 consumes: the UI obtains one from
/// [ScannerService.startScan], renders [result] on the confirmation screen,
/// lets the user [correct] any field or [retry] the analysis, and finally
/// [confirm]s to persist. The object is deliberately mutable — the UI holds it
/// for the lifetime of the review screen.
class ScanSession {
  ScanSession({
    required this.service,
    required this.input,
    required ItemAttributes attributes,
    this.photoPath = '',
  })  : _original = attributes,
        _result = attributes;

  /// The service that runs the analysis and owns the database.
  final ScannerService service;

  /// The decoded photo this session analyzes; retained so [retry] can re-run
  /// the classifier without capturing again.
  final ScanImageInput input;

  /// On-disk photo path recorded on the persisted `wardrobe_item` row.
  final String photoPath;

  ItemAttributes _original;
  ItemAttributes _result;
  bool _confirmed = false;

  /// The scanner's most recent untouched suggestion. [result] diverges from it
  /// once a field is [correct]ed; [retry] replaces it with a fresh analysis.
  ItemAttributes get original => _original;

  /// The current, possibly user-edited attributes to render and persist.
  ItemAttributes get result => _result;

  /// Whether the user has changed anything since the last analysis.
  bool get isEdited => _result.source != AttributeSource.ai;

  /// Whether [result] contains an attribute below [kLowConfidenceThreshold];
  /// the confirmation screen prompts for review when true (AI-07). Mirrors
  /// [ItemAttributes.isLowConfidence] on the current [result], so a [retry]
  /// or [correct] updates it.
  bool get isLowConfidence => _result.isLowConfidence;

  /// The [result] attribute keys that fell below the confidence threshold.
  List<String> get lowConfidenceFields => _result.lowConfidenceFields;

  /// Whether [confirm] has already persisted this scan.
  bool get isConfirmed => _confirmed;

  /// Replaces the field named [key] with [value], marking the result
  /// user-corrected.
  ///
  /// Correcting [kDominantColorKey] with a palette name (see
  /// [ColorPalette.anchors]) also refreshes the display-only Arabic name so the
  /// two never disagree; a name outside the palette keeps the previous Arabic
  /// name.
  void correct(String key, String? value) {
    _ensureEditable();
    if (key == kDominantColorKey) {
      _result = _result.copyWith(
        dominantColor: value,
        dominantColorAr: _arabicFor(value),
        source: AttributeSource.userCorrected,
      );
      return;
    }
    _result = _result.withField(key, value);
  }

  /// Re-runs the analysis on [input], discarding any corrections, and returns
  /// the fresh AI result.
  ItemAttributes retry({int colorTop = 1}) {
    _ensureEditable();
    _result = service.analyzeScan(input, colorTop: colorTop);
    _original = _result;
    return _result;
  }

  /// Confirms the reviewed result and returns the finalized [ItemAttributes].
  ///
  /// An untouched AI suggestion is recorded as
  /// [AttributeSource.userConfirmed]; a result the user edited already carries
  /// [AttributeSource.userCorrected]. Callable once — subsequent calls throw a
  /// [StateError].
  ItemAttributes confirm({String name = ''}) {
    _ensureEditable();
    _confirmed = true;
    final toConfirm = _result.source == AttributeSource.ai
        ? _result.copyWith(source: AttributeSource.userConfirmed)
        : _result;
    _result = toConfirm;
    return _result;
  }

  void _ensureEditable() {
    if (_confirmed) {
      throw StateError('This scan has already been confirmed.');
    }
  }

  static String? _arabicFor(String? name) {
    if (name == null) return null;
    for (final anchor in ColorPalette.anchors) {
      if (anchor.name == name) return anchor.nameAr;
    }
    return null;
  }
}

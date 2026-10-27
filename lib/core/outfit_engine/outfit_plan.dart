/// The engine's output contract: a per-slot outfit plan that Unity can consume
/// directly. This file is the single "final data output" definition shared with
/// the Unity and Backend teams.
library;

import 'dart:convert';

import 'garment_catalog.dart';
import 'outfit_input.dart';

const Map<ColorPreference, String> _colorHex = <ColorPreference, String>{
  ColorPreference.black: '#1A1A1A',
  ColorPreference.white: '#F5F5F0',
  ColorPreference.gray: '#8A8D91',
  ColorPreference.mustard: '#D4A017',
  ColorPreference.beige: '#D9C7A7',
  ColorPreference.burgundy: '#6E1423',
  ColorPreference.navy: '#1F2A44',
  ColorPreference.blue: '#2F5FA8',
  ColorPreference.olive: '#556B2F',
  ColorPreference.brown: '#6B4A2F',
  ColorPreference.camel: '#C19A6B',
  ColorPreference.forestGreen: '#228B22',
  ColorPreference.darkGray: '#404040',
  ColorPreference.lightOlive: '#A8B98A',
  ColorPreference.coral: '#FF6F61',
  ColorPreference.burntBrown: '#8B4513',
  ColorPreference.purple: '#6A4C93',
  ColorPreference.pink: '#F4A7B9',
};

/// Canonical material colour for tinting a garment in Unity.
String colorHexFor(ColorPreference color) => _colorHex[color] ?? '#1A1A1A';

/// One resolved garment for one avatar slot.
class GarmentAssignment {
  final GarmentSlotType slot;
  final String unitySlotKey;
  final String garmentId;
  final String garmentName;
  final String? garmentNameAr;
  final ColorPreference primaryColor;
  final ColorPreference? accentColor;
  final int warmthLevel;
  final bool modest;
  final String ruleId;
  final Set<StylePreference> styles;
  final Set<FormalityLevel> formality;
  final String? imagePath;

  const GarmentAssignment({
    required this.slot,
    required this.unitySlotKey,
    required this.garmentId,
    required this.garmentName,
    this.garmentNameAr,
    required this.primaryColor,
    this.accentColor,
    required this.warmthLevel,
    this.modest = false,
    this.ruleId = '',
    this.styles = const {},
    this.formality = const {FormalityLevel.casual},
    this.imagePath,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'slot': slot.name,
        'unitySlot': unitySlotKey,
        'garmentId': garmentId,
        'garmentName': garmentName,
        'garmentNameAr': garmentNameAr,
        'color': primaryColor.name,
        'colorHex': colorHexFor(primaryColor),
        'accent': accentColor?.name,
        'accentHex': accentColor == null ? null : colorHexFor(accentColor!),
        'warmthLevel': warmthLevel,
        'modest': modest,
        'ruleId': ruleId,
        'styles': styles.map((s) => s.name).toList(),
        'formality': formality.map((f) => f.name).toList(),
        if (imagePath != null) 'imagePath': imagePath,
      };
}

/// Human-readable explanation of the plan, for the UI and for debugging.
class OutfitContextSummary {
  final String weatherLabel;
  final TemperatureBand temperatureBand;
  final SkyCondition skyCondition;
  final Occasion occasion;
  final FormalityLevel formality;
  final Set<StylePreference> styles;
  final Set<ColorPreference> colors;
  final List<String> locationCulture;
  final List<String> appliedRules;
  final List<String> reasoning;
  final double confidence;

  const OutfitContextSummary({
    required this.weatherLabel,
    required this.temperatureBand,
    required this.skyCondition,
    required this.occasion,
    required this.formality,
    this.styles = const {},
    this.colors = const {},
    this.locationCulture = const [],
    this.appliedRules = const [],
    this.reasoning = const [],
    this.confidence = 1,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'weatherLabel': weatherLabel,
        'temperatureBand': temperatureBand.name,
        'skyCondition': skyCondition.name,
        'occasion': occasion.name,
        'formality': formality.name,
        'styles': styles.map((s) => s.name).toList(),
        'colors': colors.map((c) => c.name).toList(),
        'locationCulture': locationCulture,
        'appliedRules': appliedRules,
        'reasoning': reasoning,
        'confidence': confidence,
      };
}

/// The complete, versioned payload handed to Unity.
class UnityOutfitPayload {
  static const String version = '1.0.0';

  final DateTime generatedAt;
  final List<GarmentAssignment> slots;
  final OutfitContextSummary context;

  const UnityOutfitPayload({
    required this.generatedAt,
    required this.slots,
    required this.context,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': version,
        'generatedAt': generatedAt.toUtc().toIso8601String(),
        'slots': slots.map((s) => s.toJson()).toList(),
        'context': context.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());
}
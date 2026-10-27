/// Core of the deterministic engine: builds a normalized context from an
/// [OutfitRequest], then scores catalogue candidates per slot to produce a
/// [UnityOutfitPayload].
///
/// The engine is pure (no I/O, no randomness): the same [OutfitRequest] always
/// yields the same plan, making it trivially unit-testable and reproducible
/// across app, backend and Unity.
library;

import 'garment_catalog.dart';
import 'outfit_input.dart';
import 'outfit_plan.dart';
import 'unity_slots.dart';

/// Intermediate, normalized view of a request used by the scoring pipeline.
/// Exposed for debugging/tests; the public output is [UnityOutfitPayload].
class OutfitContext {
  final OutfitRequest request;
  final String weatherLabel;
  final TemperatureBand band;
  final SkyCondition sky;
  final FormalityLevel formality;
  final Set<StylePreference> activeStyles;
  final Set<String> cultures;

  // Layer targets (Celsius band → desired insulation per slot).
  final int topWarmthTarget;
  final int bottomWarmthTarget;
  final int footwearWarmthTarget;
  final int? outerWarmthTarget; // null => do not fill the outerwear slot.

  final bool rainProtection;
  final bool windProtection;
  final bool requireModest;

  final bool needHeadwear;
  final bool needHandwear;
  final bool needNeckwear;
  final bool needEyewear;
  final bool needAccessory;

  final ColorPreference palettePrimary;
  final ColorPreference? paletteAccent;

  final List<String> appliedRules;
  final List<String> reasoning;
  final double confidence;

  const OutfitContext({
    required this.request,
    required this.weatherLabel,
    required this.band,
    required this.sky,
    required this.formality,
    required this.activeStyles,
    required this.cultures,
    required this.topWarmthTarget,
    required this.bottomWarmthTarget,
    required this.footwearWarmthTarget,
    required this.outerWarmthTarget,
    required this.rainProtection,
    required this.windProtection,
    required this.requireModest,
    required this.needHeadwear,
    required this.needHandwear,
    required this.needNeckwear,
    required this.needEyewear,
    required this.needAccessory,
    required this.palettePrimary,
    required this.paletteAccent,
    required this.appliedRules,
    required this.reasoning,
    required this.confidence,
  });
}

/// The public engine entry point.
class OutfitEngine {
  final GarmentCatalog catalog;
  final UnitySlotMap unitySlots;

  const OutfitEngine({
    this.catalog = GarmentCatalog.defaultCatalog,
    this.unitySlots = defaultUnitySlotMap,
  });

  UnityOutfitPayload recommend(OutfitRequest request) {
    final ctx = _ContextBuilder(request).build();

    final assignments = <GarmentAssignment>[];
    assignments.addAll(_resolveSlot(GarmentSlotType.top, ctx));
    if (ctx.outerWarmthTarget != null) {
      assignments.addAll(_resolveSlot(GarmentSlotType.outerwear, ctx));
    }
    assignments.addAll(_resolveSlot(GarmentSlotType.bottom, ctx));
    assignments.addAll(_resolveSlot(GarmentSlotType.footwear, ctx));
    if (ctx.needHeadwear) assignments.addAll(_resolveSlot(GarmentSlotType.headwear, ctx));
    if (ctx.needEyewear) assignments.addAll(_resolveSlot(GarmentSlotType.eyewear, ctx));
    if (ctx.needNeckwear) assignments.addAll(_resolveSlot(GarmentSlotType.neckwear, ctx));
    if (ctx.needHandwear) assignments.addAll(_resolveSlot(GarmentSlotType.handwear, ctx));
    if (ctx.needAccessory) assignments.addAll(_resolveSlot(GarmentSlotType.accessory, ctx));

    final summary = OutfitContextSummary(
      weatherLabel: ctx.weatherLabel,
      temperatureBand: ctx.band,
      skyCondition: ctx.sky,
      occasion: ctx.request.occasion,
      formality: ctx.formality,
      styles: ctx.activeStyles,
      colors: {if (ctx.paletteAccent != null) ctx.paletteAccent!, ctx.palettePrimary},
      locationCulture: ctx.cultures.toList(),
      appliedRules: ctx.appliedRules,
      reasoning: ctx.reasoning,
      confidence: ctx.confidence,
    );

    return UnityOutfitPayload(
      generatedAt: DateTime.now(),
      slots: assignments,
      context: summary,
    );
  }

  List<GarmentAssignment> _resolveSlot(GarmentSlotType slot, OutfitContext ctx) {
    final candidates = _eligible(slot, ctx);
    if (candidates.isEmpty) {
      ctx.appliedRules.add('SLOT_EMPTY_${slot.name.toUpperCase()}');
      ctx.reasoning.add('No suitable ${slot.name} candidate — skipped.');
      return const [];
    }

    var best = candidates.first;
    var bestScore = -1 << 30;
    for (final g in candidates) {
      final s = _score(g, slot, ctx);
      if (s > bestScore) {
        bestScore = s;
        best = g;
      }
    }

    return [
      GarmentAssignment(
        slot: slot,
        unitySlotKey: unitySlots.keyFor(slot),
        garmentId: best.id,
        garmentName: best.name,
        garmentNameAr: best.nameAr,
        primaryColor: _colorFor(best, ctx),
        accentColor: _accentFor(best, ctx),
        warmthLevel: best.warmthLevel,
        modest: best.modest,
        ruleId: _slotRules(slot, ctx),
        styles: best.styles,
        formality: best.formality,
        imagePath: best.imagePath,
      ),
    ];
  }

  List<Garment> _eligible(GarmentSlotType slot, OutfitContext ctx) {
    var out = catalog.forSlot(slot).where((g) => _genderAllows(g, ctx.request.gender));

    if (ctx.requireModest) {
      final modestOnly = out.where((g) => g.modest);
      if (modestOnly.isNotEmpty) {
        return modestOnly.toList();
      }
      ctx.appliedRules.add('MOD_FALLBACK_${slot.name.toUpperCase()}');
      ctx.reasoning.add('No modest ${slot.name} available — using general catalogue.');
    }
    return out.toList();
  }

  bool _genderAllows(Garment g, Gender gender) =>
      gender == Gender.unspecified || g.genders.isEmpty || g.genders.contains(gender);

  ColorPreference _colorFor(Garment g, OutfitContext ctx) {
    if (g.defaultPalette.contains(ctx.palettePrimary)) return ctx.palettePrimary;
    if (ctx.paletteAccent != null && g.defaultPalette.contains(ctx.paletteAccent)) {
      return ctx.paletteAccent!;
    }
    return g.defaultPalette.first;
  }

  ColorPreference? _accentFor(Garment g, OutfitContext ctx) {
    ColorPreference? accent;
    if (ctx.paletteAccent != null &&
        g.defaultPalette.contains(ctx.paletteAccent) &&
        ctx.paletteAccent != _colorFor(g, ctx)) {
      accent = ctx.paletteAccent;
    }
    if (g.defaultPalette.length >= 2) {
      final second = g.defaultPalette[1];
      if (second != _colorFor(g, ctx)) return second;
    }
    return accent;
  }

  String _slotRules(GarmentSlotType slot, OutfitContext ctx) {
    final parts = <String>[
      'BAND_${ctx.band.name.toUpperCase()}',
      if (ctx.rainProtection) 'RAIN',
      if (ctx.windProtection) 'WIND',
      if (ctx.requireModest) 'MODEST',
    ];
    return parts.join('|');
  }

  int _score(Garment g, GarmentSlotType slot, OutfitContext ctx) {
    if (g.id == 'scanned_input_item') {
      return 10000;
    }
    var score = 0;

    // Warmth fit vs. the band target for this slot.
    final target = switch (slot) {
      GarmentSlotType.top => ctx.topWarmthTarget,
      GarmentSlotType.bottom => ctx.bottomWarmthTarget,
      GarmentSlotType.footwear => ctx.footwearWarmthTarget,
      GarmentSlotType.outerwear => ctx.outerWarmthTarget ?? 1,
      _ => 1,
    };
    final diff = (g.warmthLevel - target).abs();
    if (diff == 0) {
      score += 2;
    } else if (diff == 1) {
      score += 1;
    } else if (diff >= 3) {
      score -= 3;
    }
    if (g.warmthLevel >= target) score += 1;

    // Formality: strong signal — except for the outer layer in extreme cold,
    // where insulation trumps labels.
    final extremeCold =
        ctx.band == TemperatureBand.freezing || ctx.band == TemperatureBand.cold;
    final formalityHit = g.formality.contains(ctx.formality);
    if (slot == GarmentSlotType.outerwear && extremeCold) {
      if (formalityHit) score += 3;
    } else {
      score += formalityHit ? 3 : -6;
    }
    if (slot == GarmentSlotType.outerwear && extremeCold) {
      final outerTarget = ctx.outerWarmthTarget ?? 1;
      if (g.warmthLevel >= outerTarget) score += 10;
      final winterPrecip = ctx.sky == SkyCondition.snow ||
          ctx.sky == SkyCondition.storm ||
          ctx.sky == SkyCondition.rain ||
          ctx.sky == SkyCondition.freezing;
      if (winterPrecip && g.waterResistant) score += 3;
      if (g.windProof) score += 2;
    }

    // Style affinity.
    var styleHits = 0;
    for (final s in ctx.activeStyles) {
      if (g.styles.contains(s)) styleHits++;
    }
    score += styleHits * 2;

    // Season affinity (soft).
    final season = _effectiveSeason(ctx.band);
    if (g.seasons.contains(SeasonTag.all) || g.seasons.contains(season)) {
      score += 1;
    }

    // Weather protection.
    if (ctx.rainProtection) {
      score += g.waterResistant ? 5 : -4;
    }
    if (ctx.windProtection) {
      score += g.windProof ? 3 : -2;
    }
    if ((ctx.band == TemperatureBand.heat || ctx.band == TemperatureBand.warm) && g.breathable) {
      score += 3;
    }

    // Occasion-driven boosts.
    if ((ctx.request.occasion == Occasion.sport || ctx.request.occasion == Occasion.outdoor) &&
        g.styles.contains(StylePreference.sportswear)) {
      score += 3;
    }
    // Sport occasions want supportive (not bare) footwear.
    if (ctx.request.occasion == Occasion.sport &&
        slot == GarmentSlotType.footwear &&
        g.styles.contains(StylePreference.sportswear) &&
        g.warmthLevel >= 1) {
      score += 2;
    }

    // Heat/sun handling.
    if (ctx.band == TemperatureBand.heat && ctx.sky == SkyCondition.clear) {
      if (g.id == 'sun_hat') score += 2;
    }

    // Modest preference when required (candidates already filtered).
    if (ctx.requireModest && g.modest) score += 2;

    // Culture boosts (Gulf / Middle East).
    if (ctx.cultures.contains('gulf')) {
      if (g.id == 'thobe' && ctx.request.gender == Gender.male) score += 6;
      if (g.id == 'ghutra' && ctx.request.gender == Gender.male) score += 5;
      if (g.id == 'abaya' && ctx.request.gender == Gender.female) score += 6;
    }
    if (ctx.cultures.contains('mideast') && ctx.request.gender == Gender.female) {
      if (g.id == 'hijab' && ctx.requireModest) score += 5;
      if (g.id == 'abaya') score += 5;
    }

    // Comfort guards against obviously wrong picks.
    if ((ctx.band == TemperatureBand.heat || ctx.band == TemperatureBand.warm) && g.warmthLevel >= 3) {
      score -= 8;
    }
    if ((ctx.band == TemperatureBand.freezing || ctx.band == TemperatureBand.cold) &&
        (slot == GarmentSlotType.top ||
            slot == GarmentSlotType.bottom ||
            slot == GarmentSlotType.outerwear) &&
        g.warmthLevel <= 1) {
      score -= 5;
    }
    if ((ctx.band == TemperatureBand.freezing || ctx.band == TemperatureBand.cold) &&
        slot == GarmentSlotType.footwear &&
        g.warmthLevel <= 1) {
      score -= 4;
    }

    return score;
  }
}

SeasonTag _effectiveSeason(TemperatureBand band) => switch (band) {
      TemperatureBand.heat || TemperatureBand.warm => SeasonTag.summer,
      TemperatureBand.cool => SeasonTag.autumn,
      TemperatureBand.cold || TemperatureBand.freezing => SeasonTag.winter,
      TemperatureBand.mild => SeasonTag.spring,
    };

/// Builds an [OutfitContext] from a request, recording rules and reasoning so
/// the final payload explains itself.
class _ContextBuilder {
  final OutfitRequest request;
  final List<String> _rules = <String>[];
  final List<String> _reasoning = <String>[];

  _ContextBuilder(this.request);

  OutfitContext build() {
    final weather = request.weather;
    final sky = weather.sky;
    final band = weather.band;

    // Occasion → formality, escalated by style preference.
    var formality = _formalityForOccasion(request.occasion);
    final primaryStyle = request.styles.isEmpty
        ? StylePreference.casual
        : request.styles.styles.first;
    if (primaryStyle == StylePreference.businessFormal && formality.index < FormalityLevel.business.index) {
      formality = FormalityLevel.business;
    } else if (primaryStyle == StylePreference.smartCasual && formality == FormalityLevel.casual) {
      formality = FormalityLevel.smart;
    }

    // Active styles = user styles + optionally the scanned anchor item's style.
    final activeStyles = <StylePreference>{...request.styles.styles};
    final anchorStyle = request.anchorItem?.style;
    if (anchorStyle != null && anchorStyle.trim().isNotEmpty) {
      final parsed = StylePreference.fromString(anchorStyle);
      if (parsed != StylePreference.casual || activeStyles.isEmpty) {
        activeStyles.add(parsed);
      }
    }
    if (activeStyles.isEmpty) activeStyles.add(StylePreference.casual);

    // Location culture tags.
    final cultures = _cultureTags(request.location.country);

    final requireModest = request.occasion == Occasion.religious ||
        ((_modestRegion(cultures)) &&
            request.gender != Gender.male);

    // Warmth targets per band.
    final topTarget = switch (band) {
      TemperatureBand.freezing => 4,
      TemperatureBand.cold => 3,
      TemperatureBand.cool => 2,
      TemperatureBand.mild => 1,
      TemperatureBand.warm => 1,
      TemperatureBand.heat => 0,
    };
    final bottomTarget = switch (band) {
      TemperatureBand.freezing => 3,
      TemperatureBand.cold => 2,
      TemperatureBand.cool => 2,
      TemperatureBand.mild => 1,
      TemperatureBand.warm => 0,
      TemperatureBand.heat => 0,
    };
    final footwearTarget = switch (band) {
      TemperatureBand.freezing => 3,
      TemperatureBand.cold => 2,
      TemperatureBand.cool => 1,
      TemperatureBand.mild => 1,
      TemperatureBand.warm => 1,
      TemperatureBand.heat => 0,
    };

    final rainProtection = sky == SkyCondition.rain ||
        sky == SkyCondition.storm ||
        sky == SkyCondition.freezing;
    final windProtection = weather.windKph >= 25;

    // Outer layer: skipped only when it is hot and dry.
    int? outerTarget;
    if (band == TemperatureBand.heat || band == TemperatureBand.warm) {
      if (rainProtection) {
        outerTarget = 1;
      }
    } else {
      outerTarget = switch (band) {
        TemperatureBand.freezing => 4,
        TemperatureBand.cold => 3,
        TemperatureBand.cool => 2,
        _ => 1,
      };
    }

    final skyIsSunny = weather.isDay && (sky == SkyCondition.clear || sky == SkyCondition.cloudy);
    final needHeadwear =
        (band == TemperatureBand.heat && skyIsSunny) ||
        band == TemperatureBand.freezing ||
        band == TemperatureBand.cold ||
        requireModest ||
        cultures.contains('gulf') ||
        request.occasion == Occasion.outdoor;
    final needEyewear = skyIsSunny &&
        (band == TemperatureBand.heat ||
            request.occasion == Occasion.sport ||
            request.occasion == Occasion.outdoor ||
            request.occasion == Occasion.travel);
    final needHandwear = band == TemperatureBand.freezing ||
        (band == TemperatureBand.cold &&
            (windProtection || sky == SkyCondition.snow));
    final needNeckwear =
        band == TemperatureBand.freezing || band == TemperatureBand.cold;
    final needAccessory = formality.index >= FormalityLevel.business.index ||
        request.occasion == Occasion.travel ||
        request.occasion == Occasion.outdoor;

    // Palette.
    final palette = _selectPalette(activeStyles, request.styles.colors, band, sky);

    // Reasoning + rules.
    _rules.add('BAND_${band.name.toUpperCase()}');
    _reasoning.add('${weather.effectiveTempC.round()}°C (${band.name}) — layer targets '
        'top $topTarget / bottom $bottomTarget / shoes $footwearTarget.');
    switch (band) {
      case TemperatureBand.heat:
        _reasoning.add('Heat: prefer lightweight, breathable layers.');
      case TemperatureBand.cold || TemperatureBand.freezing:
        _reasoning.add('Cold weather: add insulation, hand/neck protection.');
      default:
        break;
    }
    switch (sky) {
      case SkyCondition.rain:
        _rules.add('RAIN');
        _reasoning.add('Rain: waterproof outer layer required.');
      case SkyCondition.snow:
        _rules.add('SNOW');
        _reasoning.add('Snow: keep outer layer water-resistant and warm.');
      case SkyCondition.storm:
        _rules.add('STORM');
        _reasoning.add('Storm: prioritize protection from precipitation.');
      case SkyCondition.freezing:
        _rules.add('FREEZING_RAIN');
        _reasoning.add('Freezing rain: icy — avoid bare feet, add outer layer.');
      default:
        break;
    }
    if (windProtection) {
      _rules.add('WIND');
      _reasoning.add('Wind ${weather.windKph.round()} km/h: prefer wind-proof outer layer.');
    }
    if (requireModest) {
      _rules.add('MODEST');
      _reasoning.add('Modest dress respected for occasion/region.');
    }
    if (cultures.contains('gulf')) {
      _rules.add('CULTURE_GULF');
      _reasoning.add('Gulf region: prefer local modest/national garments.');
    } else if (cultures.contains('mideast')) {
      _rules.add('CULTURE_MIDEAST');
      _reasoning.add('Middle East region: modest bottom/top preferred.');
    }

    // Confidence: penalize inferred/unknown inputs.
    var confidence = 1.0;
    if (weather.conditionCode == null) {
      confidence -= 0.05;
    }
    if (request.styles.styles.isEmpty && request.styles.colors.isEmpty) {
      confidence -= 0.05;
    }
    if (request.location.country.trim().isEmpty) confidence -= 0.05;
    if (confidence < 0.7) confidence = 0.7;

    final weatherLabel = request.weather.conditionText ?? sky.name;
    final safeLabel = weatherLabel.isEmpty && sky == SkyCondition.clear
        ? 'Clear'
        : weatherLabel;

    return OutfitContext(
      request: request,
      weatherLabel: '$safeLabel · ${request.weather.effectiveTempC.round()}°C',
      band: band,
      sky: sky,
      formality: formality,
      activeStyles: activeStyles,
      cultures: cultures,
      topWarmthTarget: topTarget,
      bottomWarmthTarget: bottomTarget,
      footwearWarmthTarget: footwearTarget,
      outerWarmthTarget: outerTarget,
      rainProtection: rainProtection,
      windProtection: windProtection,
      requireModest: requireModest,
      needHeadwear: needHeadwear,
      needHandwear: needHandwear,
      needNeckwear: needNeckwear,
      needEyewear: needEyewear,
      needAccessory: needAccessory,
      palettePrimary: palette.$1,
      paletteAccent: palette.$2,
      appliedRules: List.of(_rules),
      reasoning: List.of(_reasoning),
      confidence: confidence,
    );
  }

  FormalityLevel _formalityForOccasion(Occasion occasion) => switch (occasion) {
        Occasion.casual || Occasion.home || Occasion.outdoor || Occasion.sport => FormalityLevel.casual,
        Occasion.party || Occasion.travel || Occasion.religious => FormalityLevel.smart,
        Occasion.work || Occasion.businessMeeting => FormalityLevel.business,
        Occasion.formal => FormalityLevel.formal,
      };

  (ColorPreference, ColorPreference?) _selectPalette(
    Set<StylePreference> styles,
    Set<ColorPreference> preferred,
    TemperatureBand band,
    SkyCondition sky,
  ) {
    if (preferred.isNotEmpty) {
      final list = preferred.toList();
      return (list.first, list.length > 1 ? list[1] : null);
    }

    final fallback = switch (styles.first) {
      StylePreference.minimalist => const <ColorPreference>[ColorPreference.black, ColorPreference.white, ColorPreference.gray],
      StylePreference.classic => const <ColorPreference>[ColorPreference.navy, ColorPreference.camel, ColorPreference.beige],
      StylePreference.streetwear => const <ColorPreference>[ColorPreference.black, ColorPreference.gray, ColorPreference.olive],
      StylePreference.businessFormal => const <ColorPreference>[ColorPreference.navy, ColorPreference.darkGray, ColorPreference.white],
      StylePreference.sportswear => const <ColorPreference>[ColorPreference.navy, ColorPreference.gray, ColorPreference.coral],
      StylePreference.smartCasual => const <ColorPreference>[ColorPreference.navy, ColorPreference.beige, ColorPreference.white],
      StylePreference.casual => const <ColorPreference>[ColorPreference.blue, ColorPreference.beige, ColorPreference.gray],
    };

    // Heat + sun → prefer light shades to reflect heat.
    final lightHeat = band == TemperatureBand.heat &&
        (sky == SkyCondition.clear || sky == SkyCondition.cloudy) &&
        (styles.first != StylePreference.streetwear);
    if (lightHeat) {
      return (ColorPreference.white, ColorPreference.beige);
    }
    return (fallback.first, fallback.length > 1 ? fallback[1] : null);
  }

  bool _modestRegion(Set<String> cultures) =>
      cultures.contains('gulf') || cultures.contains('mideast');

  Set<String> _cultureTags(String country) {
    final c = country.trim().toUpperCase();
    final tags = <String>{};

    const gulfCodes = <String>{'AE', 'SA', 'QA', 'KW', 'BH', 'OM'};
    const gulfNames = <String>{
      'UAE', 'EMIRATES', 'SAUDI ARABIA', 'SAUDI', 'QATAR', 'KUWAIT',
      'BAHRAIN', 'OMAN', 'RIYADH', 'DUBAI', 'DOHA',
    };
    const mideastCodes = <String>{'EG', 'JO', 'IQ', 'SY', 'LB', 'PS', 'YE', 'TR'};
    const mideastNames = <String>{
      'EGYPT', 'JORDAN', 'IRAQ', 'SYRIA', 'LEBANON', 'PALESTINE', 'YEMEN',
      'TURKEY',
    };

    final isGulf =
        gulfCodes.contains(c) || gulfNames.any((n) => c.contains(n));
    final isMidEast = isGulf ||
        mideastCodes.contains(c) ||
        mideastNames.any((n) => c.contains(n));

    if (isGulf) {
      tags.add('gulf');
      tags.add('mideast');
    } else if (isMidEast) {
      tags.add('mideast');
    }
    if (tags.isEmpty) tags.add('general');
    return tags;
  }
}
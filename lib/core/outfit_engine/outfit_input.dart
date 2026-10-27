/// Input contract for the deterministic outfit recommendation engine.
///
/// Every input the engine reads is declared here so callers (app features,
/// the backend, or unit tests) can build an [OutfitRequest] without touching
/// engine internals. Fields with a safe default fall back to that default so
/// a call can always produce a plan.
library;

/// Gender used for culture-sensitive catalogue filtering.
enum Gender {
  male,
  female,
  unspecified;

  static Gender fromString(String value) {
    switch (value.toLowerCase().replaceAll(' ', '').replaceAll('_', '')) {
      case 'male':
      case 'man':
        return Gender.male;
      case 'female':
      case 'woman':
        return Gender.female;
      default:
        return Gender.unspecified;
    }
  }
}

/// The event/meeting type the user is preparing for.
///
/// Mirrors the backend `Attributes.Event` / `meeting_type` vocabulary so the
/// same value understood by the Outfit AI service is understood here.
enum Occasion {
  casual,
  work,
  businessMeeting,
  formal,
  party,
  sport,
  outdoor,
  travel,
  religious,
  home;

  static Occasion fromAlias(String value) {
    switch (_normalize(value)) {
      case 'casual':
      case 'daily':
      case 'everyday':
      case 'gathering':
      case 'hangingout':
      case 'chill':
        return Occasion.casual;
      case 'work':
      case 'office':
      case 'workday':
      case 'professional':
        return Occasion.work;
      case 'businessmeeting':
      case 'meeting':
      case 'interview':
      case 'presentation':
        return Occasion.businessMeeting;
      case 'formal':
      case 'wedding':
      case 'ceremony':
      case 'gala':
      case 'elegant':
        return Occasion.formal;
      case 'party':
      case 'night':
      case 'nightout':
      case 'clubbing':
      case 'date':
        return Occasion.party;
      case 'sport':
      case 'gym':
      case 'workout':
      case 'training':
      case 'running':
        return Occasion.sport;
      case 'outdoor':
      case 'picnic':
      case 'beach':
      case 'hiking':
      case 'camping':
      case 'tour':
        return Occasion.outdoor;
      case 'travel':
      case 'flight':
      case 'airport':
      case 'vacation':
        return Occasion.travel;
      case 'religious':
      case 'mosque':
      case 'masjid':
      case 'prayer':
      case 'eid':
        return Occasion.religious;
      case 'home':
      case 'relax':
      case 'downtime':
      case 'gaming':
        return Occasion.home;
      default:
        return Occasion.casual;
    }
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '');
}

/// Style preferences, mirroring the app's onboarding `StyleType` names.
enum StylePreference {
  casual,
  smartCasual,
  streetwear,
  businessFormal,
  minimalist,
  classic,
  sportswear;

  static StylePreference fromString(String value) {
    switch (value.toLowerCase().replaceAll(' ', '').replaceAll('_', '')) {
      case 'casual':
        return StylePreference.casual;
      case 'smartcasual':
        return StylePreference.smartCasual;
      case 'streetwear':
        return StylePreference.streetwear;
      case 'businessformal':
        return StylePreference.businessFormal;
      case 'minimalist':
        return StylePreference.minimalist;
      case 'classic':
        return StylePreference.classic;
      case 'sportswear':
        return StylePreference.sportswear;
      default:
        return StylePreference.casual;
    }
  }
}

/// Preferred colours, mirroring the app's onboarding `PreferredColorType`.
enum ColorPreference {
  black,
  white,
  gray,
  mustard,
  beige,
  burgundy,
  navy,
  blue,
  olive,
  brown,
  camel,
  forestGreen,
  darkGray,
  lightOlive,
  coral,
  burntBrown,
  purple,
  pink;

  static ColorPreference fromString(String value) {
    switch (value.toLowerCase().replaceAll(' ', '').replaceAll('_', '')) {
      case 'black':
        return ColorPreference.black;
      case 'white':
        return ColorPreference.white;
      case 'gray':
      case 'charcoal':
        return ColorPreference.gray;
      case 'mustard':
      case 'terracotta':
        return ColorPreference.mustard;
      case 'beige':
      case 'peach':
        return ColorPreference.beige;
      case 'burgundy':
        return ColorPreference.burgundy;
      case 'navy':
      case 'lavender':
        return ColorPreference.navy;
      case 'blue':
        return ColorPreference.blue;
      case 'olive':
      case 'sage':
        return ColorPreference.olive;
      case 'brown':
      case 'rust':
        return ColorPreference.brown;
      case 'camel':
        return ColorPreference.camel;
      case 'forestgreen':
        return ColorPreference.forestGreen;
      case 'darkgray':
        return ColorPreference.darkGray;
      case 'lightolive':
        return ColorPreference.lightOlive;
      case 'coral':
        return ColorPreference.coral;
      case 'burntbrown':
        return ColorPreference.burntBrown;
      case 'purple':
        return ColorPreference.purple;
      case 'pink':
        return ColorPreference.pink;
      default:
        return ColorPreference.black;
    }
  }
}

/// Temperature band used by the rule engine; thresholds in Celsius.
///
/// freezing < 2  ·  cold 2–10  ·  cool 10–18  ·  mild 18–26  ·  warm 26–32  ·  heat 32+
enum TemperatureBand {
  freezing,
  cold,
  cool,
  mild,
  warm,
  heat;

  static TemperatureBand forCelsius(double tempC) {
    if (tempC < 2) return TemperatureBand.freezing;
    if (tempC < 10) return TemperatureBand.cold;
    if (tempC < 18) return TemperatureBand.cool;
    if (tempC < 26) return TemperatureBand.mild;
    if (tempC < 32) return TemperatureBand.warm;
    return TemperatureBand.heat;
  }
}

/// Sky/precipitation condition grouped from the WMO weather code.
enum SkyCondition {
  clear,
  cloudy,
  rain,
  snow,
  storm,
  fog,
  freezing;

  static SkyCondition fromWmoCode(int? code) {
    if (code == null) return SkyCondition.clear;
    if (code == 0 || code == 1 || code == 2) return SkyCondition.clear;
    if (code == 45 || code == 48) return SkyCondition.fog;
    if (code == 3) return SkyCondition.cloudy;
    if (code == 51 || code == 53 || code == 55) return SkyCondition.cloudy;
    if (code == 56 || code == 57 || code == 66 || code == 67) {
      return SkyCondition.freezing;
    }
    if (code == 71 ||
        code == 73 ||
        code == 75 ||
        code == 77 ||
        code == 85 ||
        code == 86) {
      return SkyCondition.snow;
    }
    if (code >= 95 && code <= 99) return SkyCondition.storm;
    if (code == 61 || code == 63 || code == 65) return SkyCondition.rain;
    if (code == 80 || code == 81 || code == 82 || code == 96) {
      return SkyCondition.rain;
    }
    return SkyCondition.clear;
  }

  static SkyCondition fromText(String? text) {
    if (text == null || text.trim().isEmpty) return SkyCondition.clear;
    final t = text.toLowerCase();
    if (t.contains('snow') || t.contains('sleet') || t.contains('frost')) {
      return SkyCondition.snow;
    }
    if (t.contains('thunder') || t.contains('storm')) return SkyCondition.storm;
    if (t.contains('rain') || t.contains('drizzle') || t.contains('shower')) {
      return SkyCondition.rain;
    }
    if (t.contains('fog') || t.contains('mist') || t.contains('haze')) return SkyCondition.fog;
    if (t.contains('cloud') || t.contains('overcast')) return SkyCondition.cloudy;
    return SkyCondition.clear;
  }
}

/// Normalized weather the engine reasons about.
///
/// This is intentionally decoupled from the app's `WeatherModel`; map it at
/// the call site (the model only carries temp/condition text today, so wind,
/// humidity and rain are optional future inputs).
class WeatherInput {
  final double tempC;
  final double? feelsLikeC;
  final double windKph;
  final double? humidityPct;
  final double? precipitationMm;
  final int? conditionCode;
  final String? conditionText;
  final bool isDay;

  const WeatherInput({
    required this.tempC,
    this.feelsLikeC,
    this.windKph = 0,
    this.humidityPct,
    this.precipitationMm,
    this.conditionCode,
    this.conditionText,
    this.isDay = true,
  });

  /// Convenience for callers that only carry a summary (like the app's
  /// `WeatherModel`): average temp plus optional condition text.
  const WeatherInput.fromSummary({
    required double tempC,
    double? maxTempC,
    double? minTempC,
    String? conditionText,
    int? conditionCode,
  }) : this(
          tempC: tempC,
          feelsLikeC: null,
          windKph: 0,
          conditionText: conditionText,
          conditionCode: conditionCode,
        );

  double get effectiveTempC => feelsLikeC ?? tempC;

  TemperatureBand get band => TemperatureBand.forCelsius(effectiveTempC);

  SkyCondition get sky {
    if (conditionCode != null) return SkyCondition.fromWmoCode(conditionCode);
    return SkyCondition.fromText(conditionText);
  }
}

/// Where the user is. `country` drives cultural overrides; `city`/`region`
/// provide display context only for now.
class LocationInput {
  final String country;
  final String city;
  final String? region;

  const LocationInput({
    required this.country,
    this.city = '',
    this.region,
  });
}

/// Style + colour signals, matching the app's onboarding preferences.
class StylePreferences {
  final Set<StylePreference> styles;
  final Set<ColorPreference> colors;

  const StylePreferences({
    this.styles = const {},
    this.colors = const {},
  });

  bool get isEmpty => styles.isEmpty && colors.isEmpty;

  StylePreference get primaryStyle =>
      styles.isEmpty ? StylePreference.casual : styles.first;
}

/// Optional anchor item: the garment the user just scanned/wants to wear.
/// Kept loose (strings) because it mirrors the backend item-attribute DTO.
class ItemAttributesInput {
  final String? category;
  final String? color;
  final String? fit;
  final String? style;
  final String? season;
  final String? pattern;

  const ItemAttributesInput({
    this.category,
    this.color,
    this.fit,
    this.style,
    this.season,
    this.pattern,
  });
}

/// A complete recommendation request consumed by the engine.
class OutfitRequest {
  final WeatherInput weather;
  final Occasion occasion;
  final LocationInput location;
  final StylePreferences styles;
  final Gender gender;
  final ItemAttributesInput? anchorItem;

  const OutfitRequest({
    required this.weather,
    required this.location,
    this.occasion = Occasion.casual,
    this.styles = const StylePreferences(),
    this.gender = Gender.unspecified,
    this.anchorItem,
  });
}
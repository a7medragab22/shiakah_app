import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/outfit_engine/outfit_engine.dart';

void main() {
  group('enums', () {
    test('Occasion.fromAlias resolves team vocabulary', () {
      expect(Occasion.fromAlias('wedding'), Occasion.formal);
      expect(Occasion.fromAlias('business meeting'), Occasion.businessMeeting);
      expect(Occasion.fromAlias('gym'), Occasion.sport);
      expect(Occasion.fromAlias('beach'), Occasion.outdoor);
      expect(Occasion.fromAlias('Eid'), Occasion.religious);
      expect(Occasion.fromAlias('??'), Occasion.casual);
    });

    test('StylePreference mirrors app StyleType names', () {
      expect(StylePreference.fromString('Business Formal'), StylePreference.businessFormal);
      expect(StylePreference.fromString('smart_casual'), StylePreference.smartCasual);
      expect(StylePreference.fromString('streetwear'), StylePreference.streetwear);
      expect(StylePreference.fromString('??'), StylePreference.casual);
    });

    test('ColorPreference mirrors app PreferredColorType names', () {
      expect(ColorPreference.fromString('Forest Green'), ColorPreference.forestGreen);
      expect(ColorPreference.fromString('burnt_brown'), ColorPreference.burntBrown);
      expect(ColorPreference.fromString('charcoal'), ColorPreference.gray);
      expect(ColorPreference.fromString('sage'), ColorPreference.olive);
    });

    test('Gender.fromString', () {
      expect(Gender.fromString('Male'), Gender.male);
      expect(Gender.fromString('woman'), Gender.female);
      expect(Gender.fromString(''), Gender.unspecified);
    });
  });

  group('weather normalization', () {
    test('TemperatureBand boundaries in Celsius', () {
      expect(TemperatureBand.forCelsius(-5), TemperatureBand.freezing);
      expect(TemperatureBand.forCelsius(1.9), TemperatureBand.freezing);
      expect(TemperatureBand.forCelsius(2), TemperatureBand.cold);
      expect(TemperatureBand.forCelsius(9), TemperatureBand.cold);
      expect(TemperatureBand.forCelsius(10), TemperatureBand.cool);
      expect(TemperatureBand.forCelsius(17), TemperatureBand.cool);
      expect(TemperatureBand.forCelsius(18), TemperatureBand.mild);
      expect(TemperatureBand.forCelsius(25), TemperatureBand.mild);
      expect(TemperatureBand.forCelsius(26), TemperatureBand.warm);
      expect(TemperatureBand.forCelsius(31), TemperatureBand.warm);
      expect(TemperatureBand.forCelsius(32), TemperatureBand.heat);
      expect(TemperatureBand.forCelsius(45), TemperatureBand.heat);
    });

    test('SkyCondition from WMO codes', () {
      expect(SkyCondition.fromWmoCode(0), SkyCondition.clear);
      expect(SkyCondition.fromWmoCode(2), SkyCondition.clear);
      expect(SkyCondition.fromWmoCode(3), SkyCondition.cloudy);
      expect(SkyCondition.fromWmoCode(61), SkyCondition.rain);
      expect(SkyCondition.fromWmoCode(71), SkyCondition.snow);
      expect(SkyCondition.fromWmoCode(95), SkyCondition.storm);
      expect(SkyCondition.fromWmoCode(45), SkyCondition.fog);
      expect(SkyCondition.fromWmoCode(66), SkyCondition.freezing);
      expect(SkyCondition.fromWmoCode(56), SkyCondition.freezing);
      expect(SkyCondition.fromWmoCode(null), SkyCondition.clear);
    });

    test('SkyCondition from text fallback', () {
      expect(SkyCondition.fromText('Light rain showers'), SkyCondition.rain);
      expect(SkyCondition.fromText('Heavy snowfall'), SkyCondition.snow);
      expect(SkyCondition.fromText('Thunderstorm'), SkyCondition.storm);
      expect(SkyCondition.fromText('Partly cloudy'), SkyCondition.cloudy);
      expect(SkyCondition.fromText(''), SkyCondition.clear);
    });

    test('WeatherInput folds feels-like into band', () {
      const base = WeatherInput(tempC: 20, conditionText: 'Sunny');
      expect(base.band, TemperatureBand.mild);
      const feelsCold = WeatherInput(tempC: 20, feelsLikeC: 7, conditionText: 'Sunny');
      expect(feelsCold.band, TemperatureBand.cold);
    });
  });

  group('garment catalog', () {
    test('is seeded and non-empty', () {
      expect(GarmentCatalog.defaultCatalog.isEmpty, isFalse);
      expect(GarmentCatalog.defaultCatalog.items.length, greaterThan(40));
    });

    test('has unique ids', () {
      final ids = GarmentCatalog.defaultCatalog.items.map((g) => g.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('core slots all have candidates', () {
      const core = [
        GarmentSlotType.top,
        GarmentSlotType.outerwear,
        GarmentSlotType.bottom,
        GarmentSlotType.footwear,
      ];
      for (final slot in core) {
        expect(
          GarmentCatalog.defaultCatalog.forSlot(slot).length,
          greaterThanOrEqualTo(5),
          reason: 'slot $slot needs candidates',
        );
      }
      for (final slot in GarmentSlotType.values) {
        expect(
          GarmentCatalog.defaultCatalog.forSlot(slot).isNotEmpty,
          isTrue,
          reason: 'slot $slot has no garments',
        );
      }
    });

    test('every garment has a default palette colour', () {
      for (final g in GarmentCatalog.defaultCatalog.items) {
        expect(g.defaultPalette, isNotEmpty, reason: '${g.id} has no palette');
        expect(g.defaultPalette.length, greaterThanOrEqualTo(2),
            reason: '${g.id} needs at least 2 colours');
      }
    });
  });

  group('unity slot map', () {
    test('default map covers every slot type', () {
      for (final slot in GarmentSlotType.values) {
        expect(defaultUnitySlotMap.keyFor(slot), isNotEmpty);
      }
    });

    test('keys are the documented placeholders', () {
      expect(defaultUnitySlotMap.keyFor(GarmentSlotType.top), 'Shirt');
      expect(defaultUnitySlotMap.keyFor(GarmentSlotType.bottom), 'Pants');
      expect(defaultUnitySlotMap.keyFor(GarmentSlotType.footwear), 'Shoes');
    });
  });

  group('output payload', () {
    test('toJson produces the Unity contract shape', () {
      final payload = UnityOutfitPayload(
        generatedAt: DateTime.utc(2026, 10, 6),
        slots: [
          GarmentAssignment(
            slot: GarmentSlotType.top,
            unitySlotKey: 'Shirt',
            garmentId: 'basic_tee',
            garmentName: 'Basic cotton tee',
            primaryColor: ColorPreference.white,
            warmthLevel: 1,
            ruleId: 'RULE_TEST',
          ),
        ],
        context: const OutfitContextSummary(
          weatherLabel: 'Sunny · 34°C',
          temperatureBand: TemperatureBand.heat,
          skyCondition: SkyCondition.clear,
          occasion: Occasion.casual,
          formality: FormalityLevel.casual,
        ),
      );

      final json = payload.toJson();
      expect(json['version'], UnityOutfitPayload.version);
      expect(json['slots'], isA<List>());
      final slot = (json['slots'] as List).first as Map<String, dynamic>;
      expect(slot['unitySlot'], 'Shirt');
      expect(slot['garmentId'], 'basic_tee');
      expect(slot['colorHex'], '#F5F5F0');
      expect(slot['ruleId'], 'RULE_TEST');
      expect(slot['accentHex'], isNull);
      final context = json['context'] as Map<String, dynamic>;
      expect(context['formality'], 'casual');
      expect(context['appliedRules'], isEmpty);
    });

    test('toJsonString is valid JSON', () {
      final payload = UnityOutfitPayload(
        generatedAt: DateTime.utc(2026, 10, 6),
        slots: const [],
        context: const OutfitContextSummary(
          weatherLabel: 'Cloudy · 15°C',
          temperatureBand: TemperatureBand.cool,
          skyCondition: SkyCondition.cloudy,
          occasion: Occasion.work,
          formality: FormalityLevel.smart,
        ),
      );
      final decoded = jsonDecode(payload.toJsonString());
      expect(decoded['context']['occasion'], 'work');
      expect(decoded['slots'], isEmpty);
    });
  });

  group('engine end-to-end scenarios', () {
    const engine = OutfitEngine();

    GarmentAssignment? bySlot(List<GarmentAssignment> slots, GarmentSlotType slot) {
      for (final a in slots) {
        if (a.slot == slot) return a;
      }
      return null;
    }

    test('heat + casual + Cairo + male: light layers, no outerwear', () {
      final plan = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: 38, conditionCode: 0, conditionText: 'Sunny'),
        location: LocationInput(country: 'Egypt', city: 'Cairo'),
        gender: Gender.male,
      ));
      expect(bySlot(plan.slots, GarmentSlotType.top)?.garmentId, 'tank_top');
      expect(bySlot(plan.slots, GarmentSlotType.outerwear), isNull);
      expect(bySlot(plan.slots, GarmentSlotType.bottom)?.garmentId, 'shorts');
      expect(bySlot(plan.slots, GarmentSlotType.footwear)?.garmentId, 'sandals');
      expect(bySlot(plan.slots, GarmentSlotType.headwear)?.garmentId, 'sun_hat');
      expect(bySlot(plan.slots, GarmentSlotType.eyewear)?.garmentId, 'sunglasses');
      expect(bySlot(plan.slots, GarmentSlotType.accessory), isNull);
      expect(plan.context.temperatureBand, TemperatureBand.heat);
      expect(plan.context.formality, FormalityLevel.casual);
    });

    test('freezing + work + Riyadh + male + business formal: insulated business', () {
      final plan = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: -2, conditionCode: 73, conditionText: 'Snow'),
        location: LocationInput(country: 'Saudi Arabia', city: 'Riyadh'),
        occasion: Occasion.work,
        gender: Gender.male,
        styles: StylePreferences(styles: {StylePreference.businessFormal}),
      ));
      expect(bySlot(plan.slots, GarmentSlotType.top)?.garmentId, 'turtleneck');
      expect(bySlot(plan.slots, GarmentSlotType.outerwear)?.garmentId, 'parka');
      expect(bySlot(plan.slots, GarmentSlotType.bottom)?.garmentId, 'formal_trousers');
      expect(bySlot(plan.slots, GarmentSlotType.footwear)?.garmentId, 'oxford_shoes');
      expect(bySlot(plan.slots, GarmentSlotType.headwear)?.garmentId, 'ghutra');
      expect(bySlot(plan.slots, GarmentSlotType.handwear)?.garmentId, 'winter_gloves');
      expect(bySlot(plan.slots, GarmentSlotType.neckwear)?.garmentId, 'scarf');
      expect(bySlot(plan.slots, GarmentSlotType.accessory)?.garmentId, 'leather_belt');
      expect(plan.context.skyCondition, SkyCondition.snow);
    });

    test('rain + cool 15°C + London + female: waterproof, no sun gear', () {
      final plan = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: 15, conditionCode: 61, conditionText: 'Light rain'),
        location: LocationInput(country: 'United Kingdom', city: 'London'),
        gender: Gender.female,
      ));
      expect(bySlot(plan.slots, GarmentSlotType.outerwear)?.garmentId, 'raincoat');
      expect(bySlot(plan.slots, GarmentSlotType.top)?.garmentId, 'long_sleeve_tee');
      expect(bySlot(plan.slots, GarmentSlotType.bottom)?.garmentId, 'jeans');
      expect(bySlot(plan.slots, GarmentSlotType.footwear)?.garmentId, 'sneakers');
      expect(bySlot(plan.slots, GarmentSlotType.eyewear), isNull);
      expect(bySlot(plan.slots, GarmentSlotType.headwear), isNull);
      expect(plan.context.skyCondition, SkyCondition.rain);
    });

    test('sport + warm + Dubai + male + sportswear: active layers', () {
      final plan = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: 29, conditionCode: 1, conditionText: 'Partly cloudy'),
        location: LocationInput(country: 'UAE', city: 'Dubai'),
        occasion: Occasion.sport,
        gender: Gender.male,
        styles: StylePreferences(styles: {StylePreference.sportswear}),
      ));
      expect(bySlot(plan.slots, GarmentSlotType.top)?.garmentId, 'tank_top');
      expect(bySlot(plan.slots, GarmentSlotType.outerwear), isNull);
      expect(bySlot(plan.slots, GarmentSlotType.bottom)?.garmentId, 'shorts');
      expect(bySlot(plan.slots, GarmentSlotType.footwear)?.garmentId, 'running_shoes');
      expect(bySlot(plan.slots, GarmentSlotType.headwear)?.garmentId, 'sun_hat');
      expect(bySlot(plan.slots, GarmentSlotType.eyewear)?.garmentId, 'sunglasses');
    });

    test('mild + Medina + female: modest ensemble enforced', () {
      final plan = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: 22, conditionCode: 2, conditionText: 'Partly cloudy'),
        location: LocationInput(country: 'Saudi Arabia', city: 'Medina'),
        gender: Gender.female,
      ));
      expect(bySlot(plan.slots, GarmentSlotType.top)?.garmentId, 'tunic_top');
      expect(bySlot(plan.slots, GarmentSlotType.outerwear)?.garmentId, 'abaya');
      expect(bySlot(plan.slots, GarmentSlotType.headwear)?.garmentId, 'hijab');
      expect(bySlot(plan.slots, GarmentSlotType.bottom)?.garmentId, 'loose_pants');
      expect(bySlot(plan.slots, GarmentSlotType.top)?.modest, isTrue);
      expect(bySlot(plan.slots, GarmentSlotType.outerwear)?.modest, isTrue);
    });

    test('cold + snow + Moscow + male: warm + protective', () {
      final plan = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: 3, conditionCode: 71, conditionText: 'Light snow'),
        location: LocationInput(country: 'Russia', city: 'Moscow'),
        gender: Gender.male,
      ));
      final top = bySlot(plan.slots, GarmentSlotType.top)!;
      expect(top.warmthLevel, greaterThanOrEqualTo(2));
      expect(bySlot(plan.slots, GarmentSlotType.outerwear)?.garmentId, 'parka');
      final bottom = bySlot(plan.slots, GarmentSlotType.bottom)!;
      expect(bottom.warmthLevel, greaterThanOrEqualTo(2));
      expect(bySlot(plan.slots, GarmentSlotType.footwear)?.garmentId, 'leather_boots');
      expect(bySlot(plan.slots, GarmentSlotType.headwear)?.garmentId, 'beanie');
      expect(bySlot(plan.slots, GarmentSlotType.handwear)?.garmentId, 'winter_gloves');
      expect(bySlot(plan.slots, GarmentSlotType.neckwear)?.garmentId, 'scarf');
    });

    test('business + Cairo + female: formal under modest rules', () {
      final plan = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: 19, conditionCode: 3, conditionText: 'Overcast'),
        location: LocationInput(country: 'Egypt', city: 'Cairo'),
        occasion: Occasion.work,
        gender: Gender.female,
        styles: StylePreferences(styles: {
          StylePreference.businessFormal,
          StylePreference.classic,
        }),
      ));
      expect(plan.context.formality, FormalityLevel.business);
      expect(bySlot(plan.slots, GarmentSlotType.top)?.garmentId, 'tunic_top');
      expect(bySlot(plan.slots, GarmentSlotType.outerwear)?.garmentId, 'abaya');
      expect(bySlot(plan.slots, GarmentSlotType.bottom)?.garmentId, 'loose_pants');
      expect(bySlot(plan.slots, GarmentSlotType.footwear)?.garmentId, 'oxford_shoes');
      expect(bySlot(plan.slots, GarmentSlotType.headwear)?.garmentId, 'hijab');
      expect(bySlot(plan.slots, GarmentSlotType.accessory)?.garmentId, 'leather_belt');
    });

    test('deterministic: same request → identical slots and context', () {
      const req = OutfitRequest(
        weather: WeatherInput(tempC: 24, conditionCode: 5, conditionText: ''),
        location: LocationInput(country: 'Spain', city: 'Madrid'),
        occasion: Occasion.businessMeeting,
        gender: Gender.male,
        styles: StylePreferences(styles: {StylePreference.smartCasual}),
      );
      // generatedAt is wall-clock; the plan itself must be byte-identical.
      final a = engine.recommend(req).toJson();
      final b = engine.recommend(req).toJson();
      expect(a['slots'], b['slots']);
      expect(a['context'], b['context']);
    });

    test('confidence degrades with missing inputs', () {
      final inferred = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: 20),
        location: LocationInput(country: ''),
      ));
      // No condition code, no styles/colors, no country → three penalties.
      expect(inferred.context.confidence, closeTo(0.85, 1e-9));
      final full = engine.recommend(const OutfitRequest(
        weather: WeatherInput(tempC: 20, conditionCode: 1),
        location: LocationInput(country: 'Germany', city: 'Berlin'),
        styles: StylePreferences(styles: {StylePreference.classic}),
      ));
      expect(full.context.confidence, 1.0);
    });
  });
}
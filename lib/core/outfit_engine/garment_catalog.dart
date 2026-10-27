/// Garment catalogue: the universe of wearable items the rule engine can
/// assign to the avatar.
///
/// The catalogue is a seed dataset. It is meant to be reviewed by the
/// Front-end/Unity teams and later replaced or extended by a content-driven
/// source (JSON/bundle) while keeping the same [Garment] shape.
library;

import 'outfit_input.dart';

/// Logical wear slot on the avatar. `unitySlot` names live in `unity_slots.dart`.
enum GarmentSlotType {
  top,
  outerwear,
  bottom,
  footwear,
  headwear,
  eyewear,
  handwear,
  neckwear,
  accessory,
}

/// Dress-formality tier, ordered from most relaxed to most formal.
enum FormalityLevel {
  casual,
  smart,
  business,
  formal,
}

/// Seasons the garment is suited for (advisory; the engine uses these as a
/// preference signal, never as a hard gate).
enum SeasonTag {
  spring,
  summer,
  autumn,
  winter,
  all,
}

/// A single, Unity-renderable garment description. `warmthLevel` approximates
/// insulation 0 (barely insulating) to 5 (heavy winter); physical rendering
/// (meshes/materials) is owned by Unity and resolved via the `id`/slot keys.
class Garment {
  final String id;
  final String name;
  final String? nameAr;
  final GarmentSlotType slot;
  final int warmthLevel;
  final bool waterResistant;
  final bool windProof;
  final bool breathable;
  final bool modest;
  final Set<Gender> genders;
  final Set<FormalityLevel> formality;
  final Set<StylePreference> styles;
  final Set<SeasonTag> seasons;
  final List<ColorPreference> defaultPalette;
  final String? imagePath;

  const Garment({
    required this.id,
    required this.name,
    this.nameAr,
    required this.slot,
    this.warmthLevel = 1,
    this.waterResistant = false,
    this.windProof = false,
    this.breathable = false,
    this.modest = false,
    this.genders = const {},
    this.formality = const {FormalityLevel.casual},
    this.styles = const {},
    this.seasons = const {SeasonTag.all},
    this.defaultPalette = const [],
    this.imagePath,
  });
}

/// Read-only view over a list of [Garment]s.
class GarmentCatalog {
  final List<Garment> items;

  const GarmentCatalog(this.items);

  static const GarmentCatalog empty = GarmentCatalog(<Garment>[]);

  List<Garment> forSlot(GarmentSlotType slot) =>
      items.where((g) => g.slot == slot).toList();

  Garment? byId(String id) {
    for (final g in items) {
      if (g.id == id) return g;
    }
    return null;
  }

  bool get isEmpty => items.isEmpty;

  /// The seeded catalogue shipped with the engine.
  static const GarmentCatalog defaultCatalog = GarmentCatalog(_defaultGarments);
}

const List<Garment> _defaultGarments = <Garment>[
  // ── Tops ────────────────────────────────────────────────────────────────
  Garment(
    id: 'tank_top',
    name: 'Tank top',
    slot: GarmentSlotType.top,
    warmthLevel: 0,
    breathable: true,
    styles: {StylePreference.casual, StylePreference.sportswear},
    seasons: {SeasonTag.summer},
    defaultPalette: [ColorPreference.white, ColorPreference.black, ColorPreference.beige],
  ),
  Garment(
    id: 'basic_tee',
    name: 'Basic cotton tee',
    nameAr: 'تيشيرت قطني',
    slot: GarmentSlotType.top,
    warmthLevel: 1,
    breathable: true,
    styles: {
      StylePreference.casual,
      StylePreference.minimalist,
      StylePreference.streetwear,
    },
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.white, ColorPreference.black, ColorPreference.gray],
  ),
  Garment(
    id: 'long_sleeve_tee',
    name: 'Long-sleeve tee',
    slot: GarmentSlotType.top,
    warmthLevel: 2,
    styles: {StylePreference.casual, StylePreference.minimalist},
    seasons: {SeasonTag.spring, SeasonTag.autumn},
    defaultPalette: [ColorPreference.gray, ColorPreference.navy, ColorPreference.black],
  ),
  Garment(
    id: 'polo_shirt',
    name: 'Polo shirt',
    slot: GarmentSlotType.top,
    warmthLevel: 1,
    breathable: true,
    formality: {FormalityLevel.casual, FormalityLevel.smart},
    styles: {StylePreference.smartCasual, StylePreference.classic},
    seasons: {SeasonTag.spring, SeasonTag.summer},
    defaultPalette: [ColorPreference.navy, ColorPreference.white, ColorPreference.olive],
  ),
  Garment(
    id: 'button_shirt',
    name: 'Button-up shirt',
    nameAr: 'قميص بأزرار',
    slot: GarmentSlotType.top,
    warmthLevel: 1,
    formality: {FormalityLevel.casual, FormalityLevel.smart, FormalityLevel.business},
    styles: {StylePreference.classic, StylePreference.smartCasual},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.white, ColorPreference.lightOlive, ColorPreference.blue],
  ),
  Garment(
    id: 'dress_shirt',
    name: 'Dress shirt',
    slot: GarmentSlotType.top,
    warmthLevel: 1,
    formality: {FormalityLevel.business, FormalityLevel.formal},
    styles: {StylePreference.businessFormal, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.white, ColorPreference.black, ColorPreference.lightOlive],
  ),
  Garment(
    id: 'knit_sweater',
    name: 'Knit sweater',
    nameAr: 'كنزة صوف',
    slot: GarmentSlotType.top,
    warmthLevel: 3,
    styles: {StylePreference.classic, StylePreference.minimalist},
    seasons: {SeasonTag.autumn, SeasonTag.winter},
    defaultPalette: [ColorPreference.beige, ColorPreference.camel, ColorPreference.burgundy],
  ),
  Garment(
    id: 'turtleneck',
    name: 'Turtleneck',
    slot: GarmentSlotType.top,
    warmthLevel: 4,
    formality: {FormalityLevel.smart, FormalityLevel.business},
    styles: {StylePreference.minimalist, StylePreference.classic},
    seasons: {SeasonTag.winter},
    defaultPalette: [ColorPreference.black, ColorPreference.navy, ColorPreference.darkGray],
  ),
  Garment(
    id: 'hoodie',
    name: 'Hoodie',
    nameAr: 'هودي',
    slot: GarmentSlotType.top,
    warmthLevel: 2,
    styles: {
      StylePreference.streetwear,
      StylePreference.casual,
      StylePreference.sportswear,
    },
    seasons: {SeasonTag.autumn, SeasonTag.winter},
    defaultPalette: [ColorPreference.gray, ColorPreference.navy, ColorPreference.black],
  ),
  Garment(
    id: 'tunic_top',
    name: 'Tunic top',
    nameAr: 'تونيك',
    slot: GarmentSlotType.top,
    warmthLevel: 1,
    modest: true,
    genders: {Gender.female},
    formality: {FormalityLevel.casual, FormalityLevel.smart},
    styles: {StylePreference.classic, StylePreference.casual},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.camel, ColorPreference.burgundy, ColorPreference.navy],
  ),
  Garment(
    id: 'thobe',
    name: 'Thobe (kandura)',
    nameAr: 'ثوب',
    slot: GarmentSlotType.top,
    warmthLevel: 1,
    breathable: true,
    modest: true,
    genders: {Gender.male},
    formality: {FormalityLevel.smart, FormalityLevel.business},
    styles: {StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.white, ColorPreference.beige, ColorPreference.lightOlive],
  ),

  // ── Outerwear ───────────────────────────────────────────────────────────
  Garment(
    id: 'denim_jacket',
    name: 'Denim jacket',
    nameAr: 'جاكيت دينم',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 2,
    styles: {StylePreference.casual, StylePreference.streetwear},
    seasons: {SeasonTag.spring, SeasonTag.autumn},
    defaultPalette: [ColorPreference.blue, ColorPreference.black, ColorPreference.darkGray],
  ),
  Garment(
    id: 'leather_jacket',
    name: 'Leather jacket',
    nameAr: 'جاكيت جلد',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 2,
    windProof: true,
    styles: {StylePreference.streetwear, StylePreference.classic},
    seasons: {SeasonTag.autumn, SeasonTag.winter},
    defaultPalette: [ColorPreference.black, ColorPreference.brown, ColorPreference.burntBrown],
  ),
  Garment(
    id: 'blazer',
    name: 'Blazer',
    nameAr: 'بليزر',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 2,
    formality: {FormalityLevel.smart, FormalityLevel.business, FormalityLevel.formal},
    styles: {StylePreference.businessFormal, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.navy, ColorPreference.black, ColorPreference.gray],
  ),
  Garment(
    id: 'trench_coat',
    name: 'Trench coat',
    nameAr: 'ترنش كوت',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 2,
    waterResistant: true,
    formality: {FormalityLevel.smart, FormalityLevel.business},
    styles: {StylePreference.classic},
    seasons: {SeasonTag.spring, SeasonTag.autumn},
    defaultPalette: [ColorPreference.beige, ColorPreference.camel, ColorPreference.navy],
  ),
  Garment(
    id: 'parka',
    name: 'Winter parka',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 4,
    waterResistant: true,
    windProof: true,
    styles: {StylePreference.casual, StylePreference.sportswear, StylePreference.streetwear},
    seasons: {SeasonTag.winter},
    defaultPalette: [ColorPreference.navy, ColorPreference.black, ColorPreference.olive],
  ),
  Garment(
    id: 'puffer_jacket',
    name: 'Puffer jacket',
    nameAr: 'جاكيت منفوخ',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 4,
    windProof: true,
    styles: {
      StylePreference.sportswear,
      StylePreference.streetwear,
      StylePreference.minimalist,
    },
    seasons: {SeasonTag.winter},
    defaultPalette: [ColorPreference.black, ColorPreference.gray, ColorPreference.olive],
  ),
  Garment(
    id: 'windbreaker',
    name: 'Windbreaker',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 1,
    windProof: true,
    styles: {StylePreference.sportswear, StylePreference.casual},
    seasons: {SeasonTag.spring, SeasonTag.autumn},
    defaultPalette: [ColorPreference.blue, ColorPreference.navy, ColorPreference.black],
  ),
  Garment(
    id: 'cardigan',
    name: 'Cardigan',
    nameAr: 'كارديغان',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 2,
    formality: {FormalityLevel.casual, FormalityLevel.smart},
    styles: {StylePreference.classic, StylePreference.minimalist},
    seasons: {SeasonTag.spring, SeasonTag.autumn},
    defaultPalette: [ColorPreference.beige, ColorPreference.darkGray, ColorPreference.burgundy],
  ),
  Garment(
    id: 'raincoat',
    name: 'Raincoat',
    nameAr: 'معطف مطر',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 1,
    waterResistant: true,
    windProof: true,
    formality: {FormalityLevel.casual},
    styles: {StylePreference.casual, StylePreference.minimalist},
    seasons: {SeasonTag.spring, SeasonTag.autumn},
    defaultPalette: [ColorPreference.mustard, ColorPreference.navy, ColorPreference.black],
  ),
  Garment(
    id: 'abaya',
    name: 'Abaya',
    nameAr: 'عباية',
    slot: GarmentSlotType.outerwear,
    warmthLevel: 1,
    modest: true,
    genders: {Gender.female},
    formality: {FormalityLevel.smart, FormalityLevel.business, FormalityLevel.formal},
    styles: {StylePreference.classic, StylePreference.minimalist},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.darkGray, ColorPreference.navy],
  ),

  // ── Bottoms ─────────────────────────────────────────────────────────────
  Garment(
    id: 'jeans',
    name: 'Jeans',
    nameAr: 'جينز',
    slot: GarmentSlotType.bottom,
    warmthLevel: 2,
    styles: {StylePreference.casual, StylePreference.streetwear, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.blue, ColorPreference.black, ColorPreference.darkGray],
  ),
  Garment(
    id: 'chinos',
    name: 'Chinos',
    nameAr: 'شينو',
    slot: GarmentSlotType.bottom,
    warmthLevel: 1,
    formality: {FormalityLevel.smart, FormalityLevel.business},
    styles: {StylePreference.smartCasual, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.beige, ColorPreference.camel, ColorPreference.olive],
  ),
  Garment(
    id: 'cargo_pants',
    name: 'Cargo pants',
    nameAr: 'بنطال كارغو',
    slot: GarmentSlotType.bottom,
    warmthLevel: 2,
    styles: {StylePreference.streetwear, StylePreference.casual, StylePreference.sportswear},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.olive, ColorPreference.black, ColorPreference.gray],
  ),
  Garment(
    id: 'sweatpants',
    name: 'Sweatpants',
    nameAr: 'بنطال رياضي',
    slot: GarmentSlotType.bottom,
    warmthLevel: 2,
    styles: {StylePreference.sportswear, StylePreference.casual},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.gray, ColorPreference.navy, ColorPreference.black],
  ),
  Garment(
    id: 'formal_trousers',
    name: 'Formal trousers',
    slot: GarmentSlotType.bottom,
    warmthLevel: 1,
    formality: {FormalityLevel.business, FormalityLevel.formal},
    styles: {StylePreference.businessFormal, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.navy, ColorPreference.gray],
  ),
  Garment(
    id: 'shorts',
    name: 'Shorts',
    nameAr: 'شورت',
    slot: GarmentSlotType.bottom,
    warmthLevel: 0,
    breathable: true,
    styles: {StylePreference.casual, StylePreference.sportswear},
    seasons: {SeasonTag.summer},
    defaultPalette: [ColorPreference.beige, ColorPreference.navy, ColorPreference.gray],
  ),
  Garment(
    id: 'cargo_shorts',
    name: 'Cargo shorts',
    slot: GarmentSlotType.bottom,
    warmthLevel: 0,
    breathable: true,
    styles: {StylePreference.sportswear, StylePreference.casual},
    seasons: {SeasonTag.summer},
    defaultPalette: [ColorPreference.olive, ColorPreference.black, ColorPreference.beige],
  ),
  Garment(
    id: 'loose_pants',
    name: 'Loose pants',
    nameAr: 'بنطال واسع',
    slot: GarmentSlotType.bottom,
    warmthLevel: 1,
    modest: true,
    styles: {StylePreference.minimalist, StylePreference.casual, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.beige, ColorPreference.black, ColorPreference.navy],
  ),
  Garment(
    id: 'leggings',
    name: 'Leggings',
    slot: GarmentSlotType.bottom,
    warmthLevel: 1,
    styles: {StylePreference.sportswear, StylePreference.casual},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.navy, ColorPreference.darkGray],
  ),
  Garment(
    id: 'maxi_skirt',
    name: 'Maxi skirt',
    nameAr: 'تنورة طويلة',
    slot: GarmentSlotType.bottom,
    warmthLevel: 1,
    modest: true,
    genders: {Gender.female},
    formality: {FormalityLevel.smart, FormalityLevel.formal},
    styles: {StylePreference.classic, StylePreference.casual},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.burgundy, ColorPreference.black, ColorPreference.navy],
  ),

  // ── Footwear ────────────────────────────────────────────────────────────
  Garment(
    id: 'sneakers',
    name: 'Sneakers',
    nameAr: 'حذاء رياضي',
    slot: GarmentSlotType.footwear,
    warmthLevel: 1,
    styles: {StylePreference.casual, StylePreference.streetwear},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.white, ColorPreference.black, ColorPreference.navy],
  ),
  Garment(
    id: 'running_shoes',
    name: 'Running shoes',
    slot: GarmentSlotType.footwear,
    warmthLevel: 1,
    styles: {StylePreference.sportswear},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.gray, ColorPreference.coral, ColorPreference.navy],
  ),
  Garment(
    id: 'oxford_shoes',
    name: 'Oxford shoes',
    nameAr: 'حذاء أوكسفورد',
    slot: GarmentSlotType.footwear,
    warmthLevel: 1,
    formality: {FormalityLevel.business, FormalityLevel.formal, FormalityLevel.smart},
    styles: {StylePreference.businessFormal, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.burntBrown],
  ),
  Garment(
    id: 'loafers',
    name: 'Loafers',
    nameAr: 'لوفرز',
    slot: GarmentSlotType.footwear,
    warmthLevel: 1,
    formality: {FormalityLevel.smart, FormalityLevel.business},
    styles: {StylePreference.smartCasual, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.brown, ColorPreference.camel],
  ),
  Garment(
    id: 'leather_boots',
    name: 'Leather boots',
    nameAr: 'أحذية جلدية',
    slot: GarmentSlotType.footwear,
    warmthLevel: 2,
    windProof: true,
    formality: {FormalityLevel.casual, FormalityLevel.smart},
    styles: {StylePreference.classic, StylePreference.streetwear},
    seasons: {SeasonTag.autumn, SeasonTag.winter},
    defaultPalette: [ColorPreference.black, ColorPreference.burntBrown],
  ),
  Garment(
    id: 'sandals',
    name: 'Sandals',
    nameAr: 'صنادل',
    slot: GarmentSlotType.footwear,
    warmthLevel: 0,
    breathable: true,
    styles: {StylePreference.casual, StylePreference.sportswear},
    seasons: {SeasonTag.summer},
    defaultPalette: [ColorPreference.brown, ColorPreference.beige, ColorPreference.black],
  ),
  Garment(
    id: 'heeled_shoes',
    name: 'Heeled shoes',
    nameAr: 'حذاء بكعب',
    slot: GarmentSlotType.footwear,
    warmthLevel: 0,
    formality: {FormalityLevel.formal, FormalityLevel.smart},
    genders: {Gender.female},
    styles: {StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.burgundy, ColorPreference.beige],
  ),

  // ── Headwear ────────────────────────────────────────────────────────────
  Garment(
    id: 'cap',
    name: 'Baseball cap',
    nameAr: 'قبعة',
    slot: GarmentSlotType.headwear,
    warmthLevel: 0,
    styles: {StylePreference.casual, StylePreference.sportswear, StylePreference.streetwear},
    seasons: {SeasonTag.summer},
    defaultPalette: [ColorPreference.navy, ColorPreference.black, ColorPreference.gray],
  ),
  Garment(
    id: 'beanie',
    name: 'Beanie',
    nameAr: 'قبعة صوف',
    slot: GarmentSlotType.headwear,
    warmthLevel: 1,
    styles: {StylePreference.streetwear, StylePreference.casual},
    seasons: {SeasonTag.winter},
    defaultPalette: [ColorPreference.black, ColorPreference.gray, ColorPreference.mustard],
  ),
  Garment(
    id: 'sun_hat',
    name: 'Sun hat',
    slot: GarmentSlotType.headwear,
    warmthLevel: 0,
    breathable: true,
    styles: {StylePreference.casual, StylePreference.sportswear},
    seasons: {SeasonTag.summer},
    defaultPalette: [ColorPreference.beige, ColorPreference.white],
  ),
  Garment(
    id: 'hijab',
    name: 'Hijab headscarf',
    nameAr: 'حجاب',
    slot: GarmentSlotType.headwear,
    warmthLevel: 1,
    modest: true,
    genders: {Gender.female},
    styles: {StylePreference.classic, StylePreference.casual},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.beige, ColorPreference.navy],
  ),
  Garment(
    id: 'ghutra',
    name: 'Ghutra & agal',
    nameAr: 'غترة وعقال',
    slot: GarmentSlotType.headwear,
    warmthLevel: 1,
    modest: true,
    genders: {Gender.male},
    styles: {StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.white, ColorPreference.beige],
  ),

  // ── Eyewear ─────────────────────────────────────────────────────────────
  Garment(
    id: 'sunglasses',
    name: 'Sunglasses',
    nameAr: 'نظارة شمسية',
    slot: GarmentSlotType.eyewear,
    warmthLevel: 0,
    styles: {
      StylePreference.streetwear,
      StylePreference.classic,
      StylePreference.minimalist,
    },
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.brown, ColorPreference.gray],
  ),

  // ── Handwear ────────────────────────────────────────────────────────────
  Garment(
    id: 'winter_gloves',
    name: 'Winter gloves',
    nameAr: 'قفازات شتوية',
    slot: GarmentSlotType.handwear,
    warmthLevel: 2,
    windProof: true,
    styles: {StylePreference.classic, StylePreference.casual},
    seasons: {SeasonTag.winter},
    defaultPalette: [ColorPreference.black, ColorPreference.navy, ColorPreference.darkGray],
  ),

  // ── Neckwear ────────────────────────────────────────────────────────────
  Garment(
    id: 'scarf',
    name: 'Wool scarf',
    nameAr: 'وشاح صوف',
    slot: GarmentSlotType.neckwear,
    warmthLevel: 1,
    styles: {StylePreference.classic, StylePreference.minimalist},
    seasons: {SeasonTag.winter},
    defaultPalette: [ColorPreference.burgundy, ColorPreference.camel, ColorPreference.black],
  ),
  Garment(
    id: 'shemagh',
    name: 'Shemagh',
    nameAr: 'شماغ',
    slot: GarmentSlotType.neckwear,
    warmthLevel: 1,
    modest: true,
    styles: {StylePreference.sportswear, StylePreference.classic},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.mustard, ColorPreference.beige, ColorPreference.black],
  ),

  // ── Accessories ─────────────────────────────────────────────────────────
  Garment(
    id: 'crossbody_bag',
    name: 'Crossbody bag',
    nameAr: 'حقيبة كتف',
    slot: GarmentSlotType.accessory,
    warmthLevel: 0,
    styles: {StylePreference.streetwear, StylePreference.casual},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.camel, ColorPreference.olive],
  ),
  Garment(
    id: 'tote_bag',
    name: 'Tote bag',
    nameAr: 'حقيبة يد',
    slot: GarmentSlotType.accessory,
    warmthLevel: 0,
    styles: {StylePreference.minimalist, StylePreference.classic, StylePreference.casual},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.beige, ColorPreference.navy, ColorPreference.black],
  ),
  Garment(
    id: 'leather_belt',
    name: 'Leather belt',
    nameAr: 'حزام جلد',
    slot: GarmentSlotType.accessory,
    warmthLevel: 0,
    formality: {FormalityLevel.smart, FormalityLevel.business, FormalityLevel.formal},
    styles: {StylePreference.classic, StylePreference.businessFormal},
    seasons: {SeasonTag.all},
    defaultPalette: [ColorPreference.black, ColorPreference.brown, ColorPreference.burntBrown],
  ),
];
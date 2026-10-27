import '../helpers/helpers.dart';
import '../service_locator/service_locator.dart';
import 'outfit_engine.dart';

enum ClosetCheckStatus {
  success,
  emptyCloset,
  noBottoms,
  noTops,
  error,
}

class ClosetOutfitResult {
  final ClosetCheckStatus status;
  final String? message;
  final UnityOutfitPayload? payload;
  final String? topImagePath;
  final String? bottomImagePath;
  final String topColorHex;
  final String pantsColorHex;
  final List<String> outfitImages;

  const ClosetOutfitResult({
    required this.status,
    this.message,
    this.payload,
    this.topImagePath,
    this.bottomImagePath,
    this.topColorHex = '#222225',
    this.pantsColorHex = '#2B2D31',
    this.outfitImages = const [],
  });
}

class ClosetOutfitCoordinator {
  const ClosetOutfitCoordinator();

  static bool isBottomText(String text) {
    final lower = text.toLowerCase().trim();
    if (lower.isEmpty) return false;
    const bottomKeywords = [
      'pant',
      'trouser',
      'jean',
      'short',
      'skirt',
      'bottom',
      'chino',
      'jogger',
      'cargo',
      'denim',
      'legging',
      'slack',
      'sweatpant',
      'wide-leg',
      'straight-leg',
      'بنطلون',
      'بنطال',
      'جينز',
      'شورت',
      'سروال',
      'برمودا',
      'تنورة',
      'جيبة',
    ];
    return bottomKeywords.any((kw) => lower.contains(kw));
  }

  static bool isTopText(String text) {
    final lower = text.toLowerCase().trim();
    if (lower.isEmpty) return false;
    const topKeywords = [
      't-shirt',
      'shirt',
      'tee',
      'top',
      'sweater',
      'polo',
      'henley',
      'tank',
      'hoodie',
      'blouse',
      'cardigan',
      'sweatshirt',
      'jacket',
      'coat',
      'blazer',
      'pullover',
      'تيشيرت',
      'قميص',
      'بلوزة',
      'سويت شيرت',
      'هودي',
      'توب',
      'جاكيت',
      'بلوفر',
    ];
    return topKeywords.any((kw) => lower.contains(kw));
  }

  /// Accurately determines whether an input item is a bottom (pants/trousers/etc.) or a top (t-shirt/shirt/etc.).
  /// Prioritizes explicit category first, then subcategory, categoryTitle, and imagePath.
  static bool determineIsBottom({
    String? category,
    String? subcategory,
    String? categoryTitle,
    String? imagePath,
  }) {
    final cat = (category ?? '').toLowerCase().trim();
    if (cat.isNotEmpty) {
      if (isTopText(cat)) return false;
      if (isBottomText(cat)) return true;
    }

    final sub = (subcategory ?? '').toLowerCase().trim();
    if (sub.isNotEmpty) {
      if (isTopText(sub)) return false;
      if (isBottomText(sub)) return true;
    }

    final title = (categoryTitle ?? '').toLowerCase().trim();
    if (title.isNotEmpty) {
      if (isTopText(title)) return false;
      if (isBottomText(title)) return true;
    }

    final path = (imagePath ?? '').toLowerCase().trim();
    if (path.isNotEmpty) {
      if (isTopText(path)) return false;
      if (isBottomText(path)) return true;
    }

    return false;
  }

  /// Checks My Closet and generates a cohesive outfit matching the scanned item
  /// with actual clothes from the user's closet. Handles both scanned tops and scanned bottoms!
  static Future<ClosetOutfitResult> generateOutfit({
    required String imagePath,
    required String categoryTitle,
    String? category,
    String? subcategory,
    required String colorName,
    required int colorHex,
    String? fitName,
    String? patternName,
    String? styleName,
    String? seasonName,
    Occasion occasion = Occasion.casual,
    double tempC = 24.0,
    String? weatherCondition,
    Gender gender = Gender.unspecified,
  }) async {
    // 1. Ensure closet items are loaded/refreshed from API
    try {
      if (getIt.isRegistered<WardrobeRemoteDataSource>()) {
        final dataSource = getIt<WardrobeRemoteDataSource>();
        final response = await dataSource.getMyCloset();
        response.fold(
          (_) {},
          (closetData) {
            if (closetData.data?.items != null &&
                closetData.data!.items.isNotEmpty) {
              ClosetManager.instance.syncRemoteModels(closetData.data!.items);
            }
          },
        );
      }
    } catch (_) {}

    // 2. Check if closet is completely empty
    if (ClosetManager.instance.value.isEmpty &&
        ClosetManager.instance.items.isEmpty) {
      return const ClosetOutfitResult(
        status: ClosetCheckStatus.emptyCloset,
        message:
            'دولابك فارغ! لا يوجد أي ملابس في دولابك (My Closet) للتنسيق عليها. قم بإضافة ملابس أولاً لتبدأ التنسيق.',
      );
    }

    // 3. Determine if the scanned input item is a Bottom or a Top
    final bool isInputBottom = determineIsBottom(
      category: category,
      subcategory: subcategory,
      categoryTitle: categoryTitle,
      imagePath: imagePath,
    );

    // 4. Check if the required matching piece exists in user's closet
    if (isInputBottom) {
      final hasTops = ClosetManager.instance.hasTops;
      if (!hasTops) {
        return const ClosetOutfitResult(
          status: ClosetCheckStatus.noTops,
          message:
              'أنت تحاول تنسيق هذا البنطلون، ولكن لا يوجد تيشيرت أو قميص في دولابك (My Closet) للتنسيق عليه. أضف تيشيرت إلى دولابك أولاً.',
        );
      }
    } else {
      final hasBottoms = ClosetManager.instance.hasBottoms;
      if (!hasBottoms) {
        return const ClosetOutfitResult(
          status: ClosetCheckStatus.noBottoms,
          message:
              'أنت تحاول تنسيق هذا التيشرت، ولكن لا يوجد بنطلون في دولابك (My Closet) للتنسيق عليه. أضف بنطلون إلى دولابك أولاً.',
        );
      }
    }

    // 5. Build Custom Garment Catalog from User's My Closet + Scanned Item
    final catalogGarments = <Garment>[];

    // Anchor: The scanned item (slot is bottom if isInputBottom, else top)
    final anchorColorPref = ColorPreference.fromString(colorName);
    final anchorStylePref = StylePreference.fromString(styleName ?? 'casual');
    final anchorSlot =
        isInputBottom ? GarmentSlotType.bottom : GarmentSlotType.top;

    final anchorGarment = Garment(
      id: 'scanned_input_item',
      name: categoryTitle,
      slot: anchorSlot,
      warmthLevel: 1,
      imagePath: imagePath,
      defaultPalette: [anchorColorPref],
      styles: {anchorStylePref},
      formality: {
        occasion == Occasion.formal || occasion == Occasion.businessMeeting
            ? FormalityLevel.formal
            : FormalityLevel.casual
      },
    );
    catalogGarments.add(anchorGarment);

    // Map each item in user's closet
    final closetItems = ClosetManager.instance.items;
    final closetUrls = ClosetManager.instance.value;
    final matchingCandidates = isInputBottom
        ? ClosetManager.instance.tops
        : ClosetManager.instance.bottoms;

    if (closetItems.isNotEmpty) {
      for (final item in closetItems) {
        if (isInputBottom) {
          // Anchor is Bottom; map closet candidates to Top slot
          final isExplicitTop = item.isTop;
          final isDesignatedTop = matchingCandidates.contains(item);
          final isTop = isExplicitTop || isDesignatedTop;
          final isFootwear = item.isFootwear;

          // Skip other bottoms so the engine prioritizes user's anchor bottom
          if (item.isBottom && !isTop) continue;

          final slot = isTop
              ? GarmentSlotType.top
              : (isFootwear ? GarmentSlotType.footwear : GarmentSlotType.top);

          final itemColor = item.parsedAttributes.color ?? 'navy';
          final itemStyle = item.parsedAttributes.style ?? 'casual';
          final itemUrl =
              item.fullImageUrl.isNotEmpty ? item.fullImageUrl : item.imageUrl;

          catalogGarments.add(
            Garment(
              id: 'closet_item_${item.id}',
              name: item.parsedAttributes.category ??
                  (isTop ? 'T-Shirt' : (isFootwear ? 'Shoes' : 'Garment')),
              slot: slot,
              imagePath: itemUrl,
              warmthLevel: 1,
              defaultPalette: [ColorPreference.fromString(itemColor)],
              styles: {StylePreference.fromString(itemStyle)},
              formality: const {FormalityLevel.casual, FormalityLevel.formal},
            ),
          );
        } else {
          // Anchor is Top; map closet candidates to Bottom slot
          final isExplicitBottom = item.isBottom;
          final isDesignatedBottom = matchingCandidates.contains(item);
          final isBottom = isExplicitBottom || isDesignatedBottom;
          final isFootwear = item.isFootwear;

          // Skip other tops so the engine prioritizes user's anchor top
          if (item.isTop && !isBottom) continue;

          final slot = isBottom
              ? GarmentSlotType.bottom
              : (isFootwear ? GarmentSlotType.footwear : GarmentSlotType.bottom);

          final itemColor = item.parsedAttributes.color ?? 'black';
          final itemStyle = item.parsedAttributes.style ?? 'casual';
          final itemUrl =
              item.fullImageUrl.isNotEmpty ? item.fullImageUrl : item.imageUrl;

          catalogGarments.add(
            Garment(
              id: 'closet_item_${item.id}',
              name: item.parsedAttributes.category ??
                  (isBottom ? 'Pants' : (isFootwear ? 'Shoes' : 'Garment')),
              slot: slot,
              imagePath: itemUrl,
              warmthLevel: 1,
              defaultPalette: [ColorPreference.fromString(itemColor)],
              styles: {StylePreference.fromString(itemStyle)},
              formality: const {FormalityLevel.casual, FormalityLevel.formal},
            ),
          );
        }
      }
    } else {
      // Fallback if items only exist as path strings in ClosetManager
      for (int i = 0; i < closetUrls.length; i++) {
        final url = closetUrls[i];
        if (isInputBottom) {
          final isTop = isTopText(url) || i > 0 || closetUrls.length == 1;
          catalogGarments.add(
            Garment(
              id: 'closet_url_$i',
              name: isTop ? 'Closet Top' : 'Closet Item',
              slot: isTop ? GarmentSlotType.top : GarmentSlotType.bottom,
              imagePath: url,
              warmthLevel: 1,
              defaultPalette: const [
                ColorPreference.navy,
                ColorPreference.white
              ],
              styles: const {StylePreference.casual},
              formality: const {FormalityLevel.casual, FormalityLevel.formal},
            ),
          );
        } else {
          final isBottom = isBottomText(url) || i > 0 || closetUrls.length == 1;
          catalogGarments.add(
            Garment(
              id: 'closet_url_$i',
              name: isBottom ? 'Closet Pants' : 'Closet Item',
              slot: isBottom ? GarmentSlotType.bottom : GarmentSlotType.top,
              imagePath: url,
              warmthLevel: 1,
              defaultPalette: const [
                ColorPreference.black,
                ColorPreference.navy
              ],
              styles: const {StylePreference.casual},
              formality: const {FormalityLevel.casual, FormalityLevel.formal},
            ),
          );
        }
      }
    }

    // 6. Build Recommendation Request
    final userCatalog = GarmentCatalog(catalogGarments);
    final engine = OutfitEngine(catalog: userCatalog);

    final request = OutfitRequest(
      weather: WeatherInput.fromSummary(
        tempC: tempC,
        conditionText: weatherCondition,
      ),
      location: const LocationInput(country: 'Egypt', city: 'Cairo'),
      occasion: occasion,
      styles: StylePreferences(
        styles: {anchorStylePref},
        colors: {anchorColorPref},
      ),
      gender: gender,
      anchorItem: ItemAttributesInput(
        category: (category?.isNotEmpty == true) ? category! : categoryTitle,
        color: colorName,
        fit: fitName,
        style: styleName,
        season: seasonName,
        pattern: patternName,
      ),
    );

    final payload = engine.recommend(request);

    // 7. Extract Chosen Pieces
    GarmentAssignment? topPick;
    GarmentAssignment? bottomPick;

    for (final slot in payload.slots) {
      if (slot.slot == GarmentSlotType.top) topPick = slot;
      if (slot.slot == GarmentSlotType.bottom) bottomPick = slot;
    }

    final String finalTopImage;
    final String finalBottomImage;
    final String topHex;
    final String bottomHex;

    if (isInputBottom) {
      finalBottomImage = imagePath;
      final fallbackTop = matchingCandidates.isNotEmpty
          ? (matchingCandidates.first.fullImageUrl.isNotEmpty
              ? matchingCandidates.first.fullImageUrl
              : matchingCandidates.first.imageUrl)
          : (closetUrls.isNotEmpty ? closetUrls.first : '');
      finalTopImage = topPick?.imagePath ?? fallbackTop;

      bottomHex = colorHexFor(anchorColorPref);
      topHex = topPick != null
          ? colorHexFor(topPick.primaryColor)
          : '#1A1A1A';
    } else {
      finalTopImage = imagePath;
      final fallbackBottom = matchingCandidates.isNotEmpty
          ? (matchingCandidates.first.fullImageUrl.isNotEmpty
              ? matchingCandidates.first.fullImageUrl
              : matchingCandidates.first.imageUrl)
          : (closetUrls.isNotEmpty ? closetUrls.first : '');
      finalBottomImage = bottomPick?.imagePath ?? fallbackBottom;

      topHex = colorHexFor(anchorColorPref);
      bottomHex = bottomPick != null
          ? colorHexFor(bottomPick.primaryColor)
          : '#2B2D31';
    }

    final outfitImages = <String>[];
    if (finalTopImage.isNotEmpty) outfitImages.add(finalTopImage);
    if (finalBottomImage.isNotEmpty &&
        !outfitImages.contains(finalBottomImage)) {
      outfitImages.add(finalBottomImage);
    }
    if (!outfitImages.contains(imagePath) && imagePath.isNotEmpty) {
      outfitImages.insert(0, imagePath);
    }

    return ClosetOutfitResult(
      status: ClosetCheckStatus.success,
      payload: payload,
      topImagePath: finalTopImage,
      bottomImagePath: finalBottomImage,
      topColorHex: topHex,
      pantsColorHex: bottomHex,
      outfitImages: outfitImages,
    );
  }
}

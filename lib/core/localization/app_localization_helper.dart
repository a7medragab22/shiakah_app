import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../extensions/extensions.dart';
import '../local_storage/local_storage.dart';

class AppLocalizationHelper {
  AppLocalizationHelper._();

  /// Localize Location (e.g. Giza, Egypt -> الجيزة، مصر)
  static String formatLocation(BuildContext context, String cityName, String countryName) {
    if (!context.isArabic) {
      final city = cityName.trim().isEmpty ? 'Giza' : cityName.trim();
      final country = countryName.trim().isEmpty ? 'Egypt' : countryName.trim();
      return '$city, $country';
    }

    final cityLower = cityName.toLowerCase().trim();
    final countryLower = countryName.toLowerCase().trim();

    final Map<String, String> arabicCities = {
      'giza': 'الجيزة',
      'cairo': 'القاهرة',
      'alexandria': 'الإسكندرية',
      'mansoura': 'المنصورة',
      'tanta': 'طنطا',
      'zagazig': 'الزقازيق',
      'ismailia': 'الإسماعيلية',
      'port said': 'بورسعيد',
      'port_said': 'بورسعيد',
      'suez': 'السويس',
      'assiut': 'أسيوط',
      'asyut': 'أسيوط',
      'sohag': 'سوهاج',
      'luxor': 'الأقصر',
      'aswan': 'أسوان',
      'fayoum': 'الفيوم',
      'beni suef': 'بني سويف',
      'beni_suef': 'بني سويف',
      'hurghada': 'الغردقة',
      'sharm el sheikh': 'شرم الشيخ',
      'sharm_el_sheikh': 'شرم الشيخ',
      'minya': 'المنيا',
      'qena': 'قنا',
      'damietta': 'دمياط',
    };

    final Map<String, String> arabicCountries = {
      'egypt': 'مصر',
      'saudi arabia': 'المملكة العربية السعودية',
      'united arab emirates': 'الإمارات',
      'uae': 'الإمارات',
      'kuwait': 'الكويت',
      'qatar': 'قطر',
      'bahrain': 'البحرين',
      'oman': 'عُمان',
      'jordan': 'الأردن',
    };

    final localizedCity = arabicCities[cityLower] ?? (cityName.isNotEmpty ? cityName : 'الجيزة');
    final localizedCountry = arabicCountries[countryLower] ?? (countryName.isNotEmpty ? countryName : 'مصر');

    return '$localizedCity، $localizedCountry';
  }

  /// Get User Display Name (Greeting)
  static String getUserDisplayName(BuildContext context, [String? explicitName]) {
    String? name = explicitName?.trim();
    if (name == null || name.isEmpty) {
      name = HiveServiceImpl.instance.getCachedUserModel()?.name.trim();
    }

    if (name != null && name.isNotEmpty) {
      final lower = name.toLowerCase();
      if (lower == 'amgad') {
        return context.isArabic ? 'أمجد' : 'Amgad';
      }
      return name;
    }

    return context.isArabic ? 'أمجد' : 'Amgad';
  }

  /// Get User Full Name for Profile
  static String getUserFullName(BuildContext context, [String? explicitName]) {
    String? name = explicitName?.trim();
    if (name == null || name.isEmpty) {
      name = HiveServiceImpl.instance.getCachedUserModel()?.name.trim();
    }

    if (name != null && name.isNotEmpty) {
      final lower = name.toLowerCase();
      if (lower == 'amgad' || lower == 'amgad shallan') {
        return context.isArabic ? 'أمجد شعلان' : 'Amgad Shallan';
      }
      return name;
    }

    return context.isArabic ? 'أمجد شعلان' : 'Amgad Shallan';
  }

  /// Translate Color Names to active locale
  static String translateColorName(BuildContext context, String colorName) {
    if (!context.isArabic) return colorName;

    const Map<String, String> colorMap = {
      // White & Neutral
      'White': 'col_white',
      'Off White': 'col_off_white',
      'Off-White': 'col_off_white',
      'Cream': 'col_cream',
      'Ivory': 'col_ivory',
      'Beige': 'col_beige',
      'Ecru': 'col_ecru',

      // Black & Gray
      'Black': 'col_black',
      'Jet Black': 'col_jet_black',
      'Charcoal': 'col_charcoal',
      'Dark Gray': 'col_dark_gray',
      'Gray': 'col_gray',
      'Light Gray': 'col_light_gray',
      'Silver': 'col_silver',
      'Ash': 'col_ash',
      'Slate': 'col_slate',

      // Brown & Earth
      'Tan': 'col_tan',
      'Khaki': 'col_khaki',
      'Sand': 'col_sand',
      'Taupe': 'col_taupe',
      'Camel': 'col_camel',
      'Saddle': 'col_saddle',
      'Coffee': 'col_coffee',
      'Dark Brown': 'col_dark_brown',

      // Blue
      'Sky Blue': 'col_sky_blue',
      'Light Blue': 'col_light_blue',
      'Royal Blue': 'col_royal_blue',
      'Cobalt': 'col_cobalt',
      'Navy': 'col_navy',
      'Indigo': 'col_indigo',

      // Green
      'Mint': 'col_mint',
      'Sage': 'col_sage',
      'Olive': 'col_olive',
      'Army': 'col_army',
      'Green': 'col_green',
      'Dark Green': 'col_dark_green',
      'Lime': 'col_lime',

      // Red
      'Red': 'col_red',
      'Crimson': 'col_crimson',
      'Scarlet': 'col_scarlet',
      'Coral': 'col_coral',
      'Burgundy': 'col_burgundy',
      'Wine': 'col_wine',

      // Pink
      'Soft Pink': 'col_soft_pink',
      'Light Pink': 'col_light_pink',
      'Pink': 'col_pink',
      'Hot Pink': 'col_hot_pink',
      'Dusty Rose': 'col_dusty_rose',
      'Magenta': 'col_magenta',

      // Purple
      'Purple': 'col_purple',
      'Electric': 'col_electric',
      'Plum': 'col_plum',
      'Lilac': 'col_lilac',
      'Lavender': 'col_lavender',

      // Yellow
      'Gold': 'col_gold',
      'Yellow': 'col_yellow',
      'Mustard': 'col_mustard',
      'Bright Yellow': 'col_bright_yellow',

      // Orange
      'Orange': 'col_orange',
      'Burnt Orange': 'col_burnt_orange',
      'Terracotta': 'col_terracotta',
      'Peach': 'col_peach',
      'Apricot': 'col_apricot',

      // Aqua & Teal
      'Turquoise': 'col_turquoise',
      'Teal': 'col_teal',
      'Dark Teal': 'col_dark_teal',

      // Metallics
      'Rose Gold': 'col_rose_gold',
      'Bronze': 'col_bronze',
      'Gunmetal': 'col_gunmetal',
    };

    final key = colorMap[colorName];
    if (key != null) {
      final translated = key.tr();
      if (translated != key) return translated;
    }

    // Direct fallback mapping
    const directArabic = {
      'White': 'أبيض',
      'Off White': 'أوف وايت',
      'Off-White': 'أوف وايت',
      'Cream': 'كريمي',
      'Ivory': 'عاجي',
      'Beige': 'بيج',
      'Ecru': 'سكري',
      'Black': 'أسود',
      'Jet Black': 'أسود فاحم',
      'Charcoal': 'فحمي',
      'Dark Gray': 'رمادي غامق',
      'Gray': 'رمادي',
      'Light Gray': 'رمادي فاتح',
      'Silver': 'فضي',
      'Ash': 'رمادي دخاني',
      'Slate': 'رمادي أردوازي',
      'Tan': 'أسمر فاتح',
      'Khaki': 'كاكي',
      'Sand': 'رملي',
      'Taupe': 'رمادي مائل للبني',
      'Camel': 'جملي',
      'Saddle': 'جلدي',
      'Coffee': 'قهوة',
      'Dark Brown': 'بني غامق',
      'Sky Blue': 'أزرق سماوي',
      'Light Blue': 'أزرق فاتح',
      'Royal Blue': 'أزرق ملكي',
      'Cobalt': 'أزرق كوبالت',
      'Navy': 'كحلي',
      'Indigo': 'نيلي',
      'Mint': 'نعناعي',
      'Sage': 'مرمري',
      'Olive': 'زيتي',
      'Army': 'زيتي عسكري',
      'Green': 'أخضر',
      'Dark Green': 'أخضر داكن',
      'Lime': 'ليموني',
      'Red': 'أحمر',
      'Crimson': 'قرمزي',
      'Scarlet': 'أحمر قاني',
      'Coral': 'مرجاني',
      'Burgundy': 'نبيذي',
      'Wine': 'عنابي',
      'Soft Pink': 'وردي هادئ',
      'Light Pink': 'وردي فاتح',
      'Pink': 'وردي',
      'Hot Pink': 'وردي فاقع',
      'Dusty Rose': 'وردي خافت',
      'Magenta': 'ماجنتا',
      'Purple': 'بنفسجي',
      'Electric': 'بنفسجي كهربائي',
      'Plum': 'خوخي غامق',
      'Lilac': 'ليلكي',
      'Lavender': 'لافندر',
      'Gold': 'ذهبي',
      'Yellow': 'أصفر',
      'Mustard': 'خردلي',
      'Bright Yellow': 'أصفر ساطع',
      'Orange': 'برتقالي',
      'Burnt Orange': 'برتقالي محروق',
      'Terracotta': 'طوبي',
      'Peach': 'خوخي',
      'Apricot': 'مشمشي',
      'Turquoise': 'فيروزي',
      'Teal': 'تيل',
      'Dark Teal': 'تيل داكن',
      'Rose Gold': 'ذهب وردي',
      'Bronze': 'برونزي',
      'Gunmetal': 'معدني داكن',
    };

    return directArabic[colorName] ?? colorName;
  }

  /// Translate Category
  static String translateCategory(BuildContext context, String category) {
    if (!context.isArabic) return category;
    switch (category) {
      case 'Crew Neck T-Shirt': return 'cat_crew_neck'.tr();
      case 'Oversized T-Shirt': return 'cat_oversized'.tr();
      case 'V-Neck T-Shirt': return 'cat_v_neck'.tr();
      case 'Polo T-Shirt': return 'cat_polo'.tr();
      case 'Tank Top': return 'cat_tank_top'.tr();
      case 'Long Sleeve': return 'cat_long_sleeve'.tr();
      case 'Henley T-Shirt': return 'cat_henley'.tr();
      case 'Graphic T-Shirt': return 'cat_graphic'.tr();
      default: return category;
    }
  }

  /// Translate Pattern
  static String translatePattern(BuildContext context, String pattern) {
    if (!context.isArabic) return pattern;
    switch (pattern) {
      case 'Solid': return 'pat_solid'.tr();
      case 'Graphic': return 'pat_graphic'.tr();
      case 'Printed': return 'pat_printed'.tr();
      case 'Vertical Striped': return 'pat_vertical_striped'.tr();
      case 'Horizontal Striped': return 'pat_horizontal_striped'.tr();
      case 'Checked': return 'pat_checked'.tr();
      case 'Plaid': return 'pat_plaid'.tr();
      case 'Floral': return 'pat_floral'.tr();
      case 'Camouflage': return 'pat_camouflage'.tr();
      default: return pattern;
    }
  }

  /// Translate Sleeve
  static String translateSleeve(BuildContext context, String sleeve) {
    if (!context.isArabic) return sleeve;
    switch (sleeve) {
      case 'Short Sleeve': return 'slv_short'.tr();
      case 'Long Sleeve': return 'slv_long'.tr();
      case 'Sleeveless': return 'slv_sleeveless'.tr();
      case 'Raglan': return 'slv_raglan'.tr();
      default: return sleeve;
    }
  }

  /// Translate Fit
  static String translateFit(BuildContext context, String fit) {
    if (!context.isArabic) return fit;
    switch (fit) {
      case 'Regular': return 'fit_regular'.tr();
      case 'Slim': return 'fit_slim'.tr();
      case 'Relaxed': return 'fit_relaxed'.tr();
      case 'Oversized': return 'fit_oversized'.tr();
      default: return fit;
    }
  }

  /// Translate Color Category
  static String translateColorCategory(BuildContext context, String cat) {
    if (!context.isArabic) return cat;
    switch (cat) {
      case 'White & Neutral': return 'col_white_neutral'.tr();
      case 'Black & Gray': return 'col_black_gray'.tr();
      case 'Brown & Earth': return 'col_brown_earth'.tr();
      case 'Blue': return 'col_blue'.tr();
      case 'Green': return 'col_green'.tr();
      case 'Red': return 'col_red'.tr();
      case 'Pink': return 'col_pink'.tr();
      case 'Purple': return 'col_purple'.tr();
      case 'Yellow': return 'col_yellow'.tr();
      case 'Orange': return 'col_orange'.tr();
      case 'Aqua & Teal': return 'col_aqua_teal'.tr();
      case 'Metallics': return 'col_metallics'.tr();
      default: return cat;
    }
  }
}

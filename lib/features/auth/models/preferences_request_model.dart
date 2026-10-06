import 'package:equatable/equatable.dart';

enum StyleType {
  casual(1),
  smartCasual(2),
  streetwear(3),
  businessFormal(4),
  minimalist(5),
  classic(6),
  sportswear(7);

  final int value;
  const StyleType(this.value);

  static StyleType fromValue(int value) {
    return StyleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StyleType.casual,
    );
  }

  static StyleType fromString(String str) {
    switch (str.toLowerCase().replaceAll(' ', '').replaceAll('_', '')) {
      case 'casual':
        return StyleType.casual;
      case 'smartcasual':
        return StyleType.smartCasual;
      case 'streetwear':
        return StyleType.streetwear;
      case 'businessformal':
        return StyleType.businessFormal;
      case 'minimalist':
        return StyleType.minimalist;
      case 'classic':
        return StyleType.classic;
      case 'sportswear':
        return StyleType.sportswear;
      default:
        return StyleType.casual;
    }
  }
}

enum PreferredColorType {
  black(1),
  white(2),
  gray(3),
  mustard(4),
  beige(5),
  burgundy(6),
  navy(7),
  blue(8),
  olive(9),
  brown(10),
  camel(11),
  forestGreen(12),
  darkGray(13),
  lightOlive(14),
  coral(15),
  burntBrown(16),
  purple(17),
  pink(18);

  final int value;
  const PreferredColorType(this.value);

  static PreferredColorType fromValue(int value) {
    return PreferredColorType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PreferredColorType.black,
    );
  }

  static PreferredColorType fromString(String str) {
    switch (str.toLowerCase().replaceAll(' ', '').replaceAll('_', '')) {
      case 'black':
        return PreferredColorType.black;
      case 'white':
        return PreferredColorType.white;
      case 'gray':
      case 'charcoal':
        return PreferredColorType.gray;
      case 'mustard':
      case 'terracotta':
        return PreferredColorType.mustard;
      case 'beige':
      case 'peach':
        return PreferredColorType.beige;
      case 'burgundy':
        return PreferredColorType.burgundy;
      case 'navy':
      case 'lavender':
        return PreferredColorType.navy;
      case 'blue':
        return PreferredColorType.blue;
      case 'olive':
      case 'sage':
        return PreferredColorType.olive;
      case 'brown':
      case 'rust':
        return PreferredColorType.brown;
      case 'camel':
        return PreferredColorType.camel;
      case 'forestgreen':
        return PreferredColorType.forestGreen;
      case 'darkgray':
        return PreferredColorType.darkGray;
      case 'lightolive':
        return PreferredColorType.lightOlive;
      case 'coral':
        return PreferredColorType.coral;
      case 'burntbrown':
        return PreferredColorType.burntBrown;
      case 'purple':
        return PreferredColorType.purple;
      case 'pink':
        return PreferredColorType.pink;
      default:
        return PreferredColorType.black;
    }
  }
}

class PreferencesRequestModel extends Equatable {
  final List<int> styles;
  final List<int> preferredColors;

  const PreferencesRequestModel({
    required this.styles,
    required this.preferredColors,
  });

  Map<String, dynamic> toJson() => {
        'styles': styles,
        'preferredColors': preferredColors,
      };

  factory PreferencesRequestModel.fromJson(Map<String, dynamic> json) =>
      PreferencesRequestModel(
        styles: (json['styles'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        preferredColors: (json['preferredColors'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
      );

  @override
  List<Object?> get props => [styles, preferredColors];
}

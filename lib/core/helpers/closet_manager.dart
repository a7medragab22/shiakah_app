part of 'helpers.dart';

class ClosetManager extends ValueNotifier<List<String>> {
  static final ClosetManager instance = ClosetManager._internal();

  ClosetManager._internal() : super([]);

  final List<WardrobeItemModel> _items = [];
  List<WardrobeItemModel> get items => List.unmodifiable(_items);

  void addItem(String path, {WardrobeItemModel? model}) {
    final cleanPath = path.trim();
    if (cleanPath.isEmpty) return;

    if (contains(cleanPath)) return;

    value = [cleanPath, ...value];
    if (model != null) {
      _items.insert(0, model);
    } else {
      _items.insert(
        0,
        WardrobeItemModel(
          id: DateTime.now().millisecondsSinceEpoch,
          imageUrl: cleanPath,
        ),
      );
    }
  }

  WardrobeItemModel? findModel(String path) {
    final clean = path.trim().toLowerCase();
    for (final item in _items) {
      if (item.imageUrl.toLowerCase() == clean ||
          item.fullImageUrl.toLowerCase() == clean) {
        return item;
      }
      final base = extractBaseFileName(item.imageUrl);
      final pBase = extractBaseFileName(clean);
      if (base.isNotEmpty && pBase.isNotEmpty && base == pBase) {
        return item;
      }
    }
    return null;
  }

  void removeItem(String path) {
    final clean = path.trim();
    final targetBase = extractBaseFileName(clean);
    value = value.where((item) {
      final itemClean = item.trim();
      if (itemClean == clean) return false;
      if (targetBase.isNotEmpty && targetBase.length > 3) {
        final itemBase = extractBaseFileName(itemClean);
        if (itemBase == targetBase) return false;
      }
      return true;
    }).toList();
    _items.removeWhere((item) {
      if (item.imageUrl == clean || item.fullImageUrl == clean) return true;
      if (targetBase.isNotEmpty && targetBase.length > 3) {
        final imgBase = extractBaseFileName(item.imageUrl);
        final fullBase = extractBaseFileName(item.fullImageUrl);
        if (imgBase == targetBase || fullBase == targetBase) return true;
      }
      return false;
    });
  }

  static String extractBaseFileName(String path) {
    if (path.trim().isEmpty) return '';
    try {
      final withoutQuery = path.split('?').first.trim();
      final decoded = Uri.decodeComponent(withoutQuery);
      final rawName = decoded.split(Platform.pathSeparator).last.split('/').last.trim();
      if (rawName.contains('_')) {
        final afterUnderscore = rawName.substring(rawName.indexOf('_') + 1).trim();
        if (afterUnderscore.isNotEmpty && afterUnderscore.contains('.')) {
          return afterUnderscore.toLowerCase();
        }
      }
      return rawName.toLowerCase();
    } catch (_) {
      return path.split(Platform.pathSeparator).last.split('/').last.trim().toLowerCase();
    }
  }

  bool contains(String path) {
    final clean = path.trim().toLowerCase();
    if (clean.isEmpty) return false;

    if (value.any((p) => p.trim().toLowerCase() == clean)) return true;
    if (_items.any((item) =>
        item.imageUrl.toLowerCase() == clean ||
        item.fullImageUrl.toLowerCase() == clean)) {
      return true;
    }

    final targetBase = extractBaseFileName(clean);
    if (targetBase.isNotEmpty && targetBase.length > 3) {
      if (value.any((p) {
        final pBase = extractBaseFileName(p);
        return pBase == targetBase || p.toLowerCase().endsWith(targetBase);
      })) {
        return true;
      }
      if (_items.any((item) {
        final imgBase = extractBaseFileName(item.imageUrl);
        final fullBase = extractBaseFileName(item.fullImageUrl);
        return imgBase == targetBase ||
            fullBase == targetBase ||
            item.imageUrl.toLowerCase().endsWith(targetBase) ||
            item.fullImageUrl.toLowerCase().endsWith(targetBase);
      })) {
        return true;
      }
    }
    return false;
  }

  void syncRemoteItems(List<String> remotePaths) {
    final seen = <String>{};
    final seenBase = <String>{};
    final unique = <String>[];

    for (final path in remotePaths) {
      final clean = path.trim();
      if (clean.isEmpty) continue;
      if (!seen.add(clean.toLowerCase())) continue;
      final base = extractBaseFileName(clean);
      if (base.isNotEmpty && base.length > 3) {
        if (!seenBase.add(base)) continue;
      }
      unique.add(clean);
    }
    value = unique;
  }

  void syncRemoteModels(List<WardrobeItemModel> remoteModels) {
    final seenUrls = <String>{};
    final seenIds = <int>{};
    final seenBaseNames = <String>{};
    final uniqueModels = <WardrobeItemModel>[];

    for (final model in remoteModels) {
      if (model.id != 0 && !seenIds.add(model.id)) {
        continue; // duplicate ID
      }
      final url = model.fullImageUrl.isNotEmpty ? model.fullImageUrl : model.imageUrl;
      if (url.isNotEmpty && !seenUrls.add(url.toLowerCase())) {
        continue; // duplicate URL
      }
      final base = extractBaseFileName(url);
      if (base.isNotEmpty && base.length > 3) {
        if (!seenBaseNames.add(base)) {
          continue; // duplicate base filename from multiple uploads
        }
      }
      uniqueModels.add(model);
    }

    _items.clear();
    _items.addAll(uniqueModels);

    final uniqueUrls = uniqueModels
        .map((e) => e.fullImageUrl.isNotEmpty ? e.fullImageUrl : e.imageUrl)
        .where((u) => u.isNotEmpty)
        .toSet()
        .toList();

    value = uniqueUrls;
  }

  void setItems(List<String> items) {
    value = items.toSet().toList();
    _items.clear();
    for (final url in value) {
      _items.add(WardrobeItemModel(
        id: url.hashCode,
        imageUrl: url,
      ));
    }
  }

  void clear() {
    value = [];
    _items.clear();
  }

  bool get hasBottoms {
    // 1. Explicitly recognized bottom in _items
    if (_items.any((item) => item.isBottom)) return true;

    // 2. Comprehensive keyword check on raw paths/URLs
    const bottomKeywords = [
      'pant',
      'jean',
      'trouser',
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
    if (value.any((p) {
      final lp = p.toLowerCase();
      return bottomKeywords.any((kw) => lp.contains(kw));
    })) {
      return true;
    }

    // 3. Any item in closet that is NOT explicitly a top and not footwear
    // (Handles closet items with null/missing attributes or raw photos from the API)
    if (_items.any((item) => !item.isTop && !item.isFootwear)) {
      return true;
    }

    return false;
  }

  bool get hasTops {
    // 1. Explicitly recognized top in _items
    if (_items.any((item) => item.isTop)) return true;

    // 2. Comprehensive keyword check on raw paths/URLs
    const topKeywords = [
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
    if (value.any((p) {
      final lp = p.toLowerCase();
      return topKeywords.any((kw) => lp.contains(kw));
    })) {
      return true;
    }

    // 3. Any item in closet that is NOT explicitly a bottom and not footwear
    // (Handles closet items with null/missing attributes or raw photos from the API)
    if (_items.any((item) => !item.isBottom && !item.isFootwear)) {
      return true;
    }

    return false;
  }

  List<WardrobeItemModel> get bottoms {
    final explicit = _items.where((item) => item.isBottom).toList();
    if (explicit.isNotEmpty) return explicit;

    final nonTops =
        _items.where((item) => !item.isTop && !item.isFootwear).toList();
    if (nonTops.isNotEmpty) return nonTops;

    if (_items.isNotEmpty) return _items;

    return value
        .map((url) => WardrobeItemModel(id: url.hashCode, imageUrl: url))
        .toList();
  }

  List<WardrobeItemModel> get tops {
    final explicit = _items.where((item) => item.isTop).toList();
    if (explicit.isNotEmpty) return explicit;

    final nonBottoms =
        _items.where((item) => !item.isBottom && !item.isFootwear).toList();
    if (nonBottoms.isNotEmpty) return nonBottoms;

    if (_items.isNotEmpty) return _items;

    return value
        .map((url) => WardrobeItemModel(id: url.hashCode, imageUrl: url))
        .toList();
  }

  List<WardrobeItemModel> get footwear =>
      _items.where((item) => item.isFootwear).toList();
}


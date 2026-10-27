import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/outfit_engine/closet_outfit_coordinator.dart';
import 'package:shiakah/core/outfit_engine/garment_catalog.dart';
import 'package:shiakah/core/outfit_engine/outfit_input.dart';
import 'package:shiakah/features/home/data/models/my_closet_response_model.dart';

void main() {
  setUp(() {
    ClosetManager.instance.clear();
  });

  test('Empty closet check returns emptyCloset status with proper message',
      () async {
    final result = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/test_shirt.png',
      categoryTitle: 'Crew Neck T-Shirt',
      colorName: 'White',
      colorHex: 0xFFFFFFFF,
      occasion: Occasion.casual,
    );

    expect(result.status, ClosetCheckStatus.emptyCloset);
    expect(result.message, contains('دولابك فارغ'));
  });

  test('Closet with only tops returns noBottoms status', () async {
    final item = WardrobeItemModel(
      id: 1,
      imageUrl: 'https://example.com/shirt.jpg',
      attributes: {'category': 'T-Shirt', 'color': 'Black'},
    );
    ClosetManager.instance.syncRemoteModels([item]);

    final result = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/test_shirt.png',
      categoryTitle: 'Crew Neck T-Shirt',
      colorName: 'White',
      colorHex: 0xFFFFFFFF,
      occasion: Occasion.casual,
    );

    expect(result.status, ClosetCheckStatus.noBottoms);
    expect(result.message, contains('لا يوجد بنطلون في دولابك'));
  });

  test('Closet with matching bottoms returns success with coordinated outfit',
      () async {
    final pantsItem = WardrobeItemModel(
      id: 2,
      imageUrl: 'https://example.com/chinos.jpg',
      attributes: {
        'category': 'Pants',
        'color': 'Navy',
        'style': 'Smart Casual',
      },
    );
    ClosetManager.instance.syncRemoteModels([pantsItem]);

    final result = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/test_shirt.png',
      categoryTitle: 'Crew Neck T-Shirt',
      colorName: 'White',
      colorHex: 0xFFFFFFFF,
      occasion: Occasion.casual,
    );

    expect(result.status, ClosetCheckStatus.success);
    expect(result.topImagePath, 'assets/images/test_shirt.png');
    expect(result.bottomImagePath, contains('chinos.jpg'));
    expect(result.outfitImages.length, greaterThanOrEqualTo(2));
    expect(result.payload, isNotNull);
  });

  test('ClosetManager prevents duplicate items when adding local and remote paths', () {
    ClosetManager.instance.addItem('assets/images/shirt_1.jpg');
    expect(ClosetManager.instance.value.length, 1);

    // Adding same path again
    ClosetManager.instance.addItem('assets/images/shirt_1.jpg');
    expect(ClosetManager.instance.value.length, 1);

    // contains returns true for matching base filename
    expect(ClosetManager.instance.contains('https://server.com/Uploads/guid_shirt_1.jpg'), isTrue);
  });

  test('ClosetManager syncRemoteModels filters out duplicates by id, url, and base filename', () {
    final model1 = WardrobeItemModel(
      id: 10,
      imageUrl: 'https://server.com/Uploads/a1b2_pants.jpg',
      attributes: {'category': 'Pants'},
    );
    final duplicateId = WardrobeItemModel(
      id: 10,
      imageUrl: 'https://server.com/Uploads/different.jpg',
    );
    final duplicateBase = WardrobeItemModel(
      id: 11,
      imageUrl: 'https://server.com/Uploads/c3d4_pants.jpg',
    );
    final uniqueModel = WardrobeItemModel(
      id: 12,
      imageUrl: 'https://server.com/Uploads/jacket.jpg',
    );

    ClosetManager.instance.syncRemoteModels([model1, duplicateId, duplicateBase, uniqueModel]);

    // model1 and uniqueModel should be retained, duplicates dropped
    expect(ClosetManager.instance.value.length, 2);
    expect(ClosetManager.instance.items.length, 2);
  });

  test('Closet items with null attributes from server are accepted as coordinate-able bottoms', () async {
    final rawItem = WardrobeItemModel(
      id: 55,
      imageUrl: 'Images/WardrobeItems/guid_WhatsApp_Image_123.jpeg',
      attributes: null,
    );
    ClosetManager.instance.syncRemoteModels([rawItem]);

    final result = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/scanned_top.png',
      categoryTitle: 'Crew Neck T-Shirt',
      colorName: 'Pink',
      colorHex: 0xFFFFC0CB,
      occasion: Occasion.casual,
    );

    expect(result.status, ClosetCheckStatus.success);
    expect(result.bottomImagePath, contains('guid_WhatsApp_Image_123.jpeg'));
    expect(result.payload, isNotNull);
  });

  test('Closet items with Arabic keywords are recognized as bottoms', () async {
    final arabicPants = WardrobeItemModel(
      id: 77,
      imageUrl: 'Images/WardrobeItems/pants.jpeg',
      attributes: {'category': 'بنطلون جينز'},
    );
    ClosetManager.instance.syncRemoteModels([arabicPants]);

    expect(arabicPants.isBottom, isTrue);
    expect(ClosetManager.instance.hasBottoms, isTrue);

    final result = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/scanned_top.png',
      categoryTitle: 'T-Shirt',
      colorName: 'Pink',
      colorHex: 0xFFFFC0CB,
      occasion: Occasion.casual,
    );

    expect(result.status, ClosetCheckStatus.success);
  });

  test('Scanning a bottom (trousers / wide-leg pants) with tops in closet coordinates successfully', () async {
    final shirtItem = WardrobeItemModel(
      id: 88,
      imageUrl: 'https://example.com/white_tee.jpg',
      attributes: {
        'category': 'T-Shirt',
        'color': 'White',
        'style': 'Casual',
      },
    );
    ClosetManager.instance.syncRemoteModels([shirtItem]);

    final result = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/scanned_pants.png',
      categoryTitle: 'trousers',
      colorName: 'Black',
      colorHex: 0xFF000000,
      fitName: 'wide-leg pants',
      occasion: Occasion.casual,
    );

    expect(result.status, ClosetCheckStatus.success);
    expect(result.bottomImagePath, 'assets/images/scanned_pants.png');
    expect(result.topImagePath, contains('white_tee.jpg'));
    expect(result.payload, isNotNull);
  });

  test('Scanning a bottom with only bottoms in closet returns noTops status with Arabic message', () async {
    final pantsItem = WardrobeItemModel(
      id: 89,
      imageUrl: 'https://example.com/jeans.jpg',
      attributes: {
        'category': 'Pants',
        'color': 'Blue',
      },
    );
    ClosetManager.instance.syncRemoteModels([pantsItem]);

    final result = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/scanned_pants.png',
      categoryTitle: 'trousers',
      colorName: 'Black',
      colorHex: 0xFF000000,
      occasion: Occasion.casual,
    );

    expect(result.status, ClosetCheckStatus.noTops);
    expect(result.message, contains('لا يوجد تيشيرت أو قميص في دولابك'));
  });

  test('User closet items (36 burgundy t-shirt, 37 athleisure t-shirt, 38 white athleisure trousers) are classified properly and coordinate accurately', () async {
    final item36 = WardrobeItemModel(
      id: 36,
      imageUrl: 'Images/WardrobeItems/fc2f7810-a2b4-4b3c-b7d9-849efd457f2f_square_1_1_1793074433826.jpg',
      attributes: {
        'category': 't-shirt',
        'color': 'burgundy',
        'fit': 'casual',
        'style': 'casual',
        'season': 'all-season',
        'pattern': 'Solid',
      },
    );
    final item37 = WardrobeItemModel(
      id: 37,
      imageUrl: 'Images/WardrobeItems/3a523900-0d93-4936-aa41-9207124f32ea_square_1_1_1793074492411.jpg',
      attributes: {
        'category': 't-shirt',
        'color': 'black',
        'fit': 'athleisure',
        'style': 'athleisure',
        'season': 'all-season',
        'pattern': 'Solid',
      },
    );
    final item38 = WardrobeItemModel(
      id: 38,
      imageUrl: 'Images/WardrobeItems/ed40182c-0359-4f69-9ae9-1ed37b5776c1_square_1_1_1793074519341.jpg',
      attributes: {
        'category': 'trousers',
        'color': 'white',
        'fit': 'athleisure',
        'style': 'athleisure',
        'season': 'all-season',
        'pattern': 'Solid',
      },
    );

    // Verify individual model classification
    expect(item36.isTop, isTrue);
    expect(item36.isBottom, isFalse);

    // Item 37 has fit: athleisure and style: athleisure, but category is t-shirt -> must be top, NOT bottom!
    expect(item37.isTop, isTrue);
    expect(item37.isBottom, isFalse);

    // Item 38 has category: trousers -> must be bottom, NOT top!
    expect(item38.isBottom, isTrue);
    expect(item38.isTop, isFalse);

    ClosetManager.instance.syncRemoteModels([item36, item37, item38]);

    expect(ClosetManager.instance.hasTops, isTrue);
    expect(ClosetManager.instance.hasBottoms, isTrue);
    expect(ClosetManager.instance.tops.length, 2);
    expect(ClosetManager.instance.bottoms.length, 1);
    expect(ClosetManager.instance.bottoms.first.id, 38);

    // 1. Scanned item is a T-Shirt: Coordinator must pair it with Item 38 (white trousers from closet)
    final topResult = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/scanned_burgundy_top.png',
      category: 't-shirt',
      categoryTitle: 't-shirt',
      colorName: 'burgundy',
      colorHex: 0xFF800020,
      fitName: 'casual',
      styleName: 'casual',
      occasion: Occasion.casual,
    );

    expect(topResult.status, ClosetCheckStatus.success);
    expect(topResult.topImagePath, 'assets/images/scanned_burgundy_top.png');
    expect(topResult.bottomImagePath, contains('ed40182c-0359-4f69-9ae9-1ed37b5776c1'));

    // 2. Scanned item is Trousers: Coordinator must pair it with a T-shirt from closet (item 36 or 37)
    final bottomResult = await ClosetOutfitCoordinator.generateOutfit(
      imagePath: 'assets/images/scanned_jeans.png',
      category: 'trousers',
      categoryTitle: 'trousers',
      colorName: 'black',
      colorHex: 0xFF000000,
      fitName: 'athleisure',
      styleName: 'athleisure',
      occasion: Occasion.casual,
    );

    expect(bottomResult.status, ClosetCheckStatus.success);
    expect(bottomResult.bottomImagePath, 'assets/images/scanned_jeans.png');
    expect(
      (bottomResult.topImagePath?.contains('fc2f7810') ?? false) ||
          (bottomResult.topImagePath?.contains('3a523900') ?? false),
      isTrue,
    );
  });
}

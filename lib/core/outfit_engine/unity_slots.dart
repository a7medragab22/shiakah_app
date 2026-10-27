/// Mapping from the engine's logical garment slots to Unity avatar slot keys.
///
/// [`defaultUnitySlotMap`] ships placeholder keys so the engine is usable end
/// to end before the Unity team provides the real UMA garment/wardrobe slot
/// names. When the real names arrive, update the single map below — no other
/// engine code changes.
library;

import 'garment_catalog.dart';

class UnitySlotMap {
  final Map<GarmentSlotType, String> bindings;

  const UnitySlotMap(this.bindings);

  String keyFor(GarmentSlotType slot) => bindings[slot] ?? slot.name;
}

/// Placeholder keys until Unity confirms the actual UMA slot names.
///
/// Replace *values* here with e.g. `'Jacket' -> 'UMA_Jacket'` — keys
/// ([GarmentSlotType]) stay the same everywhere else.
const UnitySlotMap defaultUnitySlotMap = UnitySlotMap(<GarmentSlotType, String>{
  GarmentSlotType.top: 'Shirt',
  GarmentSlotType.outerwear: 'Jacket',
  GarmentSlotType.bottom: 'Pants',
  GarmentSlotType.footwear: 'Shoes',
  GarmentSlotType.headwear: 'Hat',
  GarmentSlotType.eyewear: 'Eyeglasses',
  GarmentSlotType.handwear: 'Gloves',
  GarmentSlotType.neckwear: 'Scarf',
  GarmentSlotType.accessory: 'Bag',
});
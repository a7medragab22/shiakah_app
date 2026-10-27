/// Deterministic outfit recommendation engine for the Unity avatar.
///
/// Consumption: import `lib/core/outfit_engine/outfit_engine.dart`.
///
/// Data flow
/// 1. Caller builds an [OutfitRequest] (weather + occasion + location + style).
/// 2. The engine (added in the rules step) resolves a garment per slot from
///    [GarmentCatalog.defaultCatalog].
/// 3. It returns a [UnityOutfitPayload] whose JSON is the contract for Unity.
library;

export 'garment_catalog.dart';
export 'outfit_input.dart';
export 'outfit_plan.dart';
export 'rules_engine.dart';
export 'unity_slots.dart';
export 'closet_outfit_coordinator.dart';
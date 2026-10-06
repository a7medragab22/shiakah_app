/// Provenance of an item attribute — where a value came from.
///
/// Values are stored in the database as the enum member name
/// (`ai`, `userConfirmed`, `userCorrected`).
enum AttributeSource { ai, userConfirmed, userCorrected }
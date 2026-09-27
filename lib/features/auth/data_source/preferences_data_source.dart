part of "../../auth/auth.dart";

abstract interface class PreferencesDataSource {
  Future<Either<Failure, PreferencesResponseModel>> updatePreferences({
    required List<int> styles,
    required List<int> preferredColors,
  });
}

class PreferencesDataSourceImpl implements PreferencesDataSource {
  final GenericDataSource _genericDataSource;
  const PreferencesDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, PreferencesResponseModel>> updatePreferences({
    required List<int> styles,
    required List<int> preferredColors,
  }) {
    final request = PreferencesRequestModel(
      styles: styles,
      preferredColors: preferredColors,
    );
    return _genericDataSource.postData<PreferencesResponseModel>(
      endpoint: Endpoints.preferences,
      data: request.toJson(),
      fromJson: (json) => PreferencesResponseModel.fromJson(json),
    );
  }
}

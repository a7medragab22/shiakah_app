import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../data/models/add_to_closet_response_model.dart';
import '../../data/services/wardrobe_remote_data_source.dart';

class AddToClosetCubit extends Cubit<BaseState<AddToClosetResponseModel>> {
  final WardrobeRemoteDataSource _dataSource;

  AddToClosetCubit(this._dataSource)
      : super(const BaseState<AddToClosetResponseModel>());

  Future<void> addToCloset(
    String imagePath, {
    String? category,
    String? color,
    String? fit,
    String? style,
    String? season,
    String? pattern,
  }) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _dataSource.addToMyCloset(
      imagePath: imagePath,
      category: category,
      color: color,
      fit: fit,
      style: style,
      season: season,
      pattern: pattern,
      addToMyCloset: true,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ));
      },
      (responseModel) {
        emit(state.copyWith(
          status: Status.success,
          data: responseModel,
          errorMessage: null,
        ));
      },
    );
  }

  void reset() {
    emit(const BaseState<AddToClosetResponseModel>());
  }
}

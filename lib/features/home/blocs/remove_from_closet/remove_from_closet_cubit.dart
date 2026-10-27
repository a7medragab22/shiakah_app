import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../data/models/remove_item_response_model.dart';
import '../../data/services/wardrobe_remote_data_source.dart';

class RemoveFromClosetCubit
    extends Cubit<BaseState<RemoveItemResponseModel>> {
  final WardrobeRemoteDataSource _dataSource;

  RemoveFromClosetCubit(this._dataSource)
      : super(const BaseState<RemoveItemResponseModel>());

  Future<void> removeItem(int itemId) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _dataSource.removeWardrobeItem(itemId: itemId);
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
    emit(const BaseState<RemoveItemResponseModel>());
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../data/models/my_closet_response_model.dart';
import '../../data/services/wardrobe_remote_data_source.dart';

class MyClosetCubit extends Cubit<BaseState<MyClosetResponseModel>> {
  final WardrobeRemoteDataSource _dataSource;

  MyClosetCubit(this._dataSource)
      : super(const BaseState<MyClosetResponseModel>());

  Future<void> fetchMyCloset() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _dataSource.getMyCloset();
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
}

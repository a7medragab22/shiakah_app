import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../data/models/my_looks_response_model.dart';
import '../../data/services/outfit_remote_data_source.dart';

class MyLooksCubit extends Cubit<BaseState<MyLooksResponseModel>> {
  final OutfitRemoteDataSource _dataSource;

  MyLooksCubit(this._dataSource)
      : super(const BaseState<MyLooksResponseModel>());

  Future<void> fetchMyLooks() async {
    emit(state.copyWith(status: Status.loading));
    final result = await _dataSource.getMyLooks();
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

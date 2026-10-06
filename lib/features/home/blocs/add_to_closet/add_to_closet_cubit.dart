import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../data/models/add_to_closet_response_model.dart';
import '../../data/services/wardrobe_remote_data_source.dart';

class AddToClosetCubit extends Cubit<BaseState<AddToClosetResponseModel>> {
  final WardrobeRemoteDataSource _dataSource;

  AddToClosetCubit(this._dataSource)
      : super(const BaseState<AddToClosetResponseModel>());

  Future<void> addToCloset(String imagePath) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _dataSource.addToMyCloset(imagePath: imagePath);
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

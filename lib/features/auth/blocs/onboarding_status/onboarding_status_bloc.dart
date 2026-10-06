import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../../../core/local_storage/local_storage.dart';
import '../../auth.dart';

class OnboardingStatusBloc
    extends Bloc<OnboardingStatusEvent, BaseState<OnboardingStatusResponseModel>> {
  final OnboardingStatusDataSource _dataSource;

  OnboardingStatusBloc(this._dataSource)
      : super(const BaseState<OnboardingStatusResponseModel>()) {
    on<OnboardingStatusRequested>(_onStatusRequested);
  }

  Future<void> _onStatusRequested(
    OnboardingStatusRequested event,
    Emitter<BaseState<OnboardingStatusResponseModel>> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));

    final result = await _dataSource.getStatus();

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
        ));
      },
      (response) async {
        final profile = response.data?.profile;
        if (profile != null) {
          try {
            final name = profile.name?.trim();
            if (name != null && name.isNotEmpty) {
              final cached = HiveServiceImpl.instance.getCachedUserModel();
              if (cached != null) {
                await HiveServiceImpl.instance.updateCachedUserModel(
                  cached.copyWith(name: name),
                );
              } else {
                await HiveServiceImpl.instance.cacheUserModel(
                  UserModel(id: 1, name: name, email: '', phone: ''),
                );
              }
            }

            final location = profile.location?.trim();
            if (location != null && location.isNotEmpty) {
              await HiveServiceImpl.put('settings_box', 'user_location', location);
            }
          } catch (_) {}
        }

        emit(state.copyWith(
          status: Status.success,
          data: response,
        ));
      },
    );
  }
}

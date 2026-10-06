import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/features/home/blocs/add_to_closet/add_to_closet_cubit.dart';
import 'package:shiakah/features/home/blocs/my_closet/my_closet_cubit.dart';
import 'package:shiakah/features/home/data/models/add_to_closet_response_model.dart';
import 'package:shiakah/features/home/data/models/my_closet_response_model.dart';
import 'package:shiakah/features/home/data/services/wardrobe_remote_data_source.dart';

class MockWardrobeRemoteDataSource implements WardrobeRemoteDataSource {
  final bool shouldFail;
  final AddToClosetResponseModel? responseModel;
  final MyClosetResponseModel? myClosetResponseModel;

  MockWardrobeRemoteDataSource({
    this.shouldFail = false,
    this.responseModel,
    this.myClosetResponseModel,
  });

  @override
  Future<Either<Failure, AddToClosetResponseModel>> addToMyCloset({
    required String imagePath,
  }) async {
    if (shouldFail) {
      return Left(ServerFailure(message: 'Failed to add item to wardrobe'));
    }
    return Right(
      responseModel ??
          const AddToClosetResponseModel(
            success: true,
            data: 25,
            message: 'WardrobeItemAddedToYourClosetSuccessfully',
          ),
    );
  }

  @override
  Future<Either<Failure, MyClosetResponseModel>> getMyCloset() async {
    if (shouldFail) {
      return Left(ServerFailure(message: 'Failed to load wardrobe items'));
    }
    return Right(
      myClosetResponseModel ??
          const MyClosetResponseModel(
            success: true,
            data: MyClosetDataModel(
              id: 14,
              items: [
                WardrobeItemModel(
                  id: 21,
                  imageUrl:
                      'Images/WardrobeItems/10e7b29d-e8bd-4406-b1ce-4835f1ea5b4f_WhatsApp Image 2026-05-08 at 7.09.15 PM.jpeg',
                ),
              ],
            ),
            message: 'WardrobeRetrievedSuccessfully',
          ),
    );
  }
}

void main() {
  group('Wardrobe Feature Tests', () {
    test('AddToClosetResponseModel parses JSON correctly', () {
      final json = {
        "success": true,
        "data": 25,
        "message": "WardrobeItemAddedToYourClosetSuccessfully",
        "errors": null,
        "meta": null,
      };

      final model = AddToClosetResponseModel.fromJson(json);

      expect(model.success, isTrue);
      expect(model.data, 25);
      expect(model.message, "WardrobeItemAddedToYourClosetSuccessfully");
      expect(model.errors, isNull);
      expect(model.meta, isNull);
    });

    test('MyClosetResponseModel parses JSON correctly with items list', () {
      final json = {
        "success": true,
        "data": {
          "id": 14,
          "items": [
            {
              "id": 21,
              "imageUrl":
                  "Images/WardrobeItems/10e7b29d-e8bd-4406-b1ce-4835f1ea5b4f_WhatsApp Image 2026-05-08 at 7.09.15 PM.jpeg",
              "attributes": null,
              "createdAt": "2026-09-27T16:48:23.0013465"
            },
            {
              "id": 22,
              "imageUrl":
                  "Images/WardrobeItems/9cd6139c-27e3-46a6-9eef-36190a830b18_WhatsApp Image 2026-05-08 at 7.09.15 PM.jpeg",
              "attributes": null,
              "createdAt": "2026-09-27T16:55:53.3516532"
            }
          ]
        },
        "message": "WardrobeRetrievedSuccessfully",
        "errors": null,
        "meta": null
      };

      final response = MyClosetResponseModel.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, "WardrobeRetrievedSuccessfully");
      expect(response.data, isNotNull);
      expect(response.data!.id, 14);
      expect(response.data!.items.length, 2);

      final firstItem = response.data!.items.first;
      expect(firstItem.id, 21);
      expect(
        firstItem.fullImageUrl,
        'https://shiakah.runasp.net/Images/WardrobeItems/10e7b29d-e8bd-4406-b1ce-4835f1ea5b4f_WhatsApp Image 2026-05-08 at 7.09.15 PM.jpeg',
      );
    });

    test('AddToClosetCubit emits loading then success on successful upload',
        () async {
      final mockDataSource = MockWardrobeRemoteDataSource();
      final cubit = AddToClosetCubit(mockDataSource);

      final expectedStates = [
        predicate<BaseState<AddToClosetResponseModel>>(
          (s) => s.status == Status.loading,
        ),
        predicate<BaseState<AddToClosetResponseModel>>(
          (s) =>
              s.status == Status.success &&
              s.data?.success == true &&
              s.data?.data == 25,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.addToCloset('assets/images/T-shirts category/1.jpg');
    });

    test('AddToClosetCubit emits loading then failure on failed upload',
        () async {
      final mockDataSource = MockWardrobeRemoteDataSource(shouldFail: true);
      final cubit = AddToClosetCubit(mockDataSource);

      final expectedStates = [
        predicate<BaseState<AddToClosetResponseModel>>(
          (s) => s.status == Status.loading,
        ),
        predicate<BaseState<AddToClosetResponseModel>>(
          (s) =>
              s.status == Status.failure &&
              s.errorMessage == 'Failed to add item to wardrobe',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.addToCloset('assets/images/T-shirts category/1.jpg');
    });

    test('MyClosetCubit emits loading then success with items', () async {
      final mockDataSource = MockWardrobeRemoteDataSource();
      final cubit = MyClosetCubit(mockDataSource);

      final expectedStates = [
        predicate<BaseState<MyClosetResponseModel>>(
          (s) => s.status == Status.loading,
        ),
        predicate<BaseState<MyClosetResponseModel>>(
          (s) =>
              s.status == Status.success &&
              s.data?.success == true &&
              s.data?.data?.items.length == 1 &&
              s.data?.data?.items.first.id == 21,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchMyCloset();
    });

    test('MyClosetCubit emits loading then failure on error', () async {
      final mockDataSource = MockWardrobeRemoteDataSource(shouldFail: true);
      final cubit = MyClosetCubit(mockDataSource);

      final expectedStates = [
        predicate<BaseState<MyClosetResponseModel>>(
          (s) => s.status == Status.loading,
        ),
        predicate<BaseState<MyClosetResponseModel>>(
          (s) =>
              s.status == Status.failure &&
              s.errorMessage == 'Failed to load wardrobe items',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchMyCloset();
    });

    test('Endpoints contains myCloset and addToMyCloset paths', () {
      expect(Endpoints.addToMyCloset, '/api/Wardrobe/add-to-my-closet');
      expect(Endpoints.myCloset, '/api/Wardrobe/my-closet');
    });
  });
}

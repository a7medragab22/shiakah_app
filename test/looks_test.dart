import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/features/home/blocs/my_looks/my_looks_cubit.dart';
import 'package:shiakah/features/home/data/models/my_looks_response_model.dart';
import 'package:shiakah/features/home/data/services/outfit_remote_data_source.dart';

class MockOutfitRemoteDataSource implements OutfitRemoteDataSource {
  final bool shouldFail;
  final MyLooksResponseModel? responseModel;

  MockOutfitRemoteDataSource({
    this.shouldFail = false,
    this.responseModel,
  });

  @override
  Future<Either<Failure, MyLooksResponseModel>> getMyLooks() async {
    if (shouldFail) {
      return Left(ServerFailure(message: 'Failed to retrieve looks'));
    }
    return Right(
      responseModel ??
          const MyLooksResponseModel(
            success: true,
            data: [
              OutfitLookModel(
                id: 7,
                top: 'Charcoal sweater',
                bottom: 'Dark wash jeans',
                footwear: 'Cream retro sneakers',
                recommendedImageUrl: 'https://images.unsplash.com/photo-1739384929658',
              ),
            ],
            message: 'OutfitResultsRetrievedSuccessfully',
          ),
    );
  }
}

void main() {
  group('My Looks Feature Tests', () {
    test('MyLooksResponseModel parses user API response correctly', () {
      final json = {
        "success": true,
        "data": [
          {
            "id": 7,
            "top": "Dark charcoal textured knit sweater",
            "bottom": "Slim-fit dark wash blue denim jeans",
            "footwear": "Cream and navy low-top retro sneakers",
            "accessories": "None visible",
            "recommendedImageUrl": "https://images.unsplash.com/photo-1739384929658-62d3d935d7ec",
            "searchQuery": "men charcoal textured knit sweater",
            "stylingTips": "To modernize the silhouette...",
            "summary": "A balanced smart-casual layered outfit...",
            "createdAt": "2026-09-27T22:40:58.038217"
          },
          {
            "id": 6,
            "top": "Textured charcoal knit crew-neck sweater",
            "bottom": "Slim-fit dark indigo washed jeans",
            "footwear": "Cream and navy low-top retro sneakers",
            "accessories": "None visible",
            "recommendedImageUrl": "Images/Looks/look_6.jpg",
            "searchQuery": "men textured crewneck sweater",
            "stylingTips": "To elevate the smart-casual balance...",
            "summary": "A clean, smart-casual outfit...",
            "createdAt": "2026-09-27T21:53:36.727767"
          }
        ],
        "message": "OutfitResultsRetrievedSuccessfully",
        "errors": null,
        "meta": null
      };

      final response = MyLooksResponseModel.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, "OutfitResultsRetrievedSuccessfully");
      expect(response.data.length, 2);

      final first = response.data[0];
      expect(first.id, 7);
      expect(first.top, "Dark charcoal textured knit sweater");
      expect(first.recommendedImageUrl, "https://images.unsplash.com/photo-1739384929658-62d3d935d7ec");
      expect(first.fullImageUrl, "https://images.unsplash.com/photo-1739384929658-62d3d935d7ec");

      final second = response.data[1];
      expect(second.id, 6);
      expect(second.fullImageUrl, "https://shiakah.runasp.net/Images/Looks/look_6.jpg");
    });

    test('Endpoints contains myLooks path', () {
      expect(Endpoints.myLooks, '/api/OutfitResult/my-looks');
    });

    test('MyLooksCubit emits loading then success with looks', () async {
      final mockDataSource = MockOutfitRemoteDataSource();
      final cubit = MyLooksCubit(mockDataSource);

      final expectedStates = [
        predicate<BaseState<MyLooksResponseModel>>(
          (s) => s.status == Status.loading,
        ),
        predicate<BaseState<MyLooksResponseModel>>(
          (s) =>
              s.status == Status.success &&
              s.data?.success == true &&
              s.data?.data.length == 1 &&
              s.data?.data.first.id == 7,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchMyLooks();
    });

    test('MyLooksCubit emits loading then failure on error', () async {
      final mockDataSource = MockOutfitRemoteDataSource(shouldFail: true);
      final cubit = MyLooksCubit(mockDataSource);

      final expectedStates = [
        predicate<BaseState<MyLooksResponseModel>>(
          (s) => s.status == Status.loading,
        ),
        predicate<BaseState<MyLooksResponseModel>>(
          (s) =>
              s.status == Status.failure &&
              s.errorMessage == 'Failed to retrieve looks',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchMyLooks();
    });
  });
}

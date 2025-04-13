import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/widgets/constants/strings.dart';

class FavoriteController {
  static Future<Either<String, String>> addFavorite({
    required String uid,
    required String favorite,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppStrings.addToFavoriteEndpoint),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: jsonEncode({'uid': uid, 'favorite': favorite}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse['message']);
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 500) {
        return const Left(AppStrings.internalServerError);
      } else {
        return const Left(AppStrings.unexpectedError);
      }
    } catch (e) {
      return const Left(AppStrings.serverError);
    }
  }

  static Future<Either<String, String>> removeFavorite({
    required String uid,
    required String favorite,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppStrings.removeFromFavoriteEndpoint),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: jsonEncode({'uid': uid, 'favorite': favorite}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse['message']);
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 500) {
        return const Left(AppStrings.internalServerError);
      } else {
        return const Left(AppStrings.unexpectedError);
      }
    } catch (e) {
      return const Left(AppStrings.serverError);
    }
  }
}

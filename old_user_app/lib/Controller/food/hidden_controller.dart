import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/widgets/constants/strings.dart';

class HideController {
  static Future<Either<String, String>> addToHide({
    required BuildContext context,
    required String uid,
    required Restaurants? restaurants,

  }) async {
    try {
      print(jsonEncode({'uid': uid, 'hidden': restaurants}));
      final response = await http.post(
        Uri.parse(AppStrings.addToHiddenEndpoint),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body:
            jsonEncode({'uid': uid, 'hidden': restaurants}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("response is ${response.body}");
        // // Update cart count in shared preferences
        // await updateCartItemCount(SharedPrefsUtil().getInt(AppStrings.cartItemCountKey)?? 0);
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

  static Future<Either<String, String>> removeFromHidden({
    required BuildContext context,
    required String uid,
    required String restaurantsID,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppStrings.removeFromHiddenEndpoint),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: jsonEncode({'uid': uid, 'hiddenRestaurants': restaurantsID}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // // Update cart count in shared preferences
        // await updateCartItemCount(SharedPrefsUtil().getInt(AppStrings.cartItemCountKey) ?? 0);
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

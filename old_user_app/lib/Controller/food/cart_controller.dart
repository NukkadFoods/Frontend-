import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/request_login.dart';

class CartController {
  static Future<Either<String, String>> addToCart({
    required BuildContext context,
    required String uid,
    required CartModel cart,
  }) async {
    if (uid.isEmpty) {
      Navigator.of(context)
          .push(transitionToNextScreen(const RequestLoginScreen()));
    }
    try {
      log({'uid': uid, 'cart': cart.toJson()}.toString());
      final response = await http.post(
        Uri.parse(AppStrings.addToCartEndpoint),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: jsonEncode({
          'uid': uid,
          "restaurantId": cart.restaurantId,
          "itemId": cart.itemId,
          "unitCost": cart.unitCost,
          "itemName": cart.itemName,
          "timetoprepare": cart.timetoprepare
          // "quantity": 1,
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
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

  static Future<Either<String, String>> removeFromCart({
    required BuildContext context,
    required String uid,
    required CartModel cart,
  }) async {

    try {
      final response = await http.post(
        Uri.parse(AppStrings.removeFromCartEndpoint),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: jsonEncode({
          'uid': uid,
          "restaurantId": cart.restaurantId,
          "itemId": cart.itemId,
          "unitCost": cart.unitCost,
          "itemName": cart.itemName,
          "timetoprepare": cart.timetoprepare
          // "quantity": 1,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      print('Response Body: ${response.body}');
      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        //  await updateCartItemCount(SharedPrefsUtil().getInt(AppStrings.cartItemCountKey) ?? 0);
        return Right(jsonResponse['message']);
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 500) {
        return const Left(AppStrings.internalServerError);
      } else {
        return const Left(AppStrings.unexpectedError);
      }
    } catch (e) {
      print('Error: $e');
      return const Left(AppStrings.serverError);
    }
  }

  static Future<void> updateCartItemCount(int itemCount) async {
    await SharedPrefsUtil().setInt(AppStrings.cartItemCountKey, itemCount);
  }
}

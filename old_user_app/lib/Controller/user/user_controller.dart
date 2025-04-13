import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';

class UserController {
  static Future<Either<String, UserModel>> getUserById({
    required String id,
    required BuildContext context,
  }) async {
    print('${AppStrings.userEndpoint}/$id');
    try {
      final response =
          await http.post(Uri.parse('${AppStrings.userEndpoint}/$id'));

      // Check the status code and response body
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print("response body : $jsonResponse");

        // Check if the response has the expected structure
        if (jsonResponse['executed'] == true) {
          final user = UserModel.fromJson(jsonResponse);

          // Store necessary user data in shared preferences
          SharedPrefsUtil().setInt(
              AppStrings.cartItemCountKey, user.user!.getCartTotalQuantity());
          SharedPrefsUtil().setDouble(
              AppStrings.cartItemTotalKey, user.user!.getCartTotal());
          SharedPrefsUtil()
              .setString(AppStrings.userNameKey, user.user!.username ?? "");
          if (context.mounted) {
            context.read<GlobalProvider>().updateCarts(user.user!.cart!);
          }

          return Right(user);
        } else {
          // Handle unexpected JSON structure
          return Left('Unexpected response format: ${response.body}');
        }
      } else if (response.statusCode == 404) {
        return Left('User not found: ${response.body}');
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left('Authorization error: ${response.body}');
      } else if (response.statusCode == 500) {
        return const Left(AppStrings.noUserFound);
      } else {
        return Left('Unknown error: ${response.body}');
      }
    } catch (e) {
      print("Error occurred: $e"); // Add this line for more detailed logs
      if (e is http.ClientException) {
        return const Left('No Internet');
      }
      return const Left(AppStrings.serverError);
    }
  }

  static Future<Either<String, UserModel>> updateUserById({
    required String id,
    required Map<String, dynamic> updateData,
    required BuildContext context,
  }) async {
    print(updateData);
    print(AppStrings.updateUserEndpoint);
    try {
      final response = await http.post(
        Uri.parse(AppStrings.updateUserEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          '_id': id,
          'updateData': updateData,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['executed'] == true) {
        print("resposne:   $jsonResponse");
        final user = UserModel.fromJson(jsonResponse);

        return Right(user);
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(jsonResponse['message']);
      } else if (response.statusCode == 500) {
        return const Left(AppStrings.noUserFound);
      } else {
        return Left(jsonResponse['message']);
      }
    } catch (e) {
      return Left('${AppStrings.serverError}$e');
    }
  }
}

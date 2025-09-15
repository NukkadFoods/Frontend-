import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/Controller/food/model/allmenu_model.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/food/model/menu_model.dart';
import 'package:user_app/widgets/constants/strings.dart';

class FoodController {
  static Future<Either<String, FetchAllRestaurantsModel>> fetchAllRestaurants({
    required BuildContext context,
  }) async {
    try {
      print(AppStrings.fetchAllRestaurantsEndpoint);
      final response =
          await http.get(Uri.parse(AppStrings.fetchAllRestaurantsEndpoint));
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final restaurants = jsonResponse["restaurants"];
        final executed = jsonResponse["executed"];

        if (restaurants != null &&
            restaurants is List &&
            restaurants.isNotEmpty &&
            executed == true) {
          final ordersModel = FetchAllRestaurantsModel.fromJson(jsonResponse);
          return Right(ordersModel);
        } else if (restaurants != null &&
            restaurants is List &&
            restaurants.isEmpty &&
            executed == true) {
          return const Left(AppStrings.noRestaurantsFound);
        } else {
          return const Left(AppStrings.failedToLoadRestaurants);
        }
      } else if (response.statusCode == 404) {
        return Left(jsonResponse['message'] ?? 'Not found');
      } else if (response.statusCode == 500) {
        return const Left(AppStrings.serverError);
      } else {
        return const Left(AppStrings.failedToLoadRestaurants);
      }
    } catch (e) {
      print(e);
      return Left("${AppStrings.serverError}:");
    }
  }

  static Future<Either<String, dynamic>> getMenuItems({
    required String uid,
    required BuildContext context,
    String? category,
    String? subCategory,
  }) async {
    try {
      print("${AppStrings.getMenuItemEndpoint}/$uid");
      final uri = Uri.parse("${AppStrings.getMenuItemEndpoint}/$uid").replace(
        queryParameters: {
          if (category != null) 'category': category,
          if (subCategory != null) 'subCategory': subCategory,
        },
      );
      final response = await http.post(uri);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (category == null && subCategory == null) {
          final menuModel = FullMenuModel.fromJson(jsonResponse);
          return Right(menuModel);
        } else if (category != null && subCategory == null) {
          final menuModel = CategoryMenuModel.fromJson(jsonResponse);
          return Right(menuModel);
        } else {
          final menuModel = SimpleMenuModel.fromJson(jsonResponse);
          return Right(menuModel);
        }
      } else if (response.statusCode == 404) {
        final message = jsonDecode(response.body)['message'] ?? 'Not found';
        return Left(message);
      } else {
        return const Left(AppStrings.failedToLoadMenuItems);
      }
    } catch (e) {
      return Left('${AppStrings.serverError}: $e');
    }
  }

  final String apiUrl = '${AppStrings.menuEndpoint}/fetchAllitems';
  Future<MenuResponse> fetchMenuItems() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MenuResponse.fromJson(data);
    } else {
      throw Exception('Failed to load menu items');
    }
  }
}

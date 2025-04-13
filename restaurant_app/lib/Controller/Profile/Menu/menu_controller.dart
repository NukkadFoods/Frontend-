import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/Controller/Profile/Menu/MenuAPI.dart';
import 'package:restaurant_app/Controller/Profile/Menu/save_menu_item.dart';
import 'package:restaurant_app/Controller/Profile/Menu/update_menu_item_model.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/show_snack_bar_extension.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/toast.dart';

class MenuControllerClass {
  // static String baseURL = "${dotenv.env['BASE_URL']}";
  static String baseURL = AppStrings.baseURL;

  static Future<Either<String, Map>> getMenuItems({
    required String uid,
    required BuildContext context,
    String? category,
    String? subCategory,
  }) async {
    try {
      print("${AppStrings.getMenuItemEndpoint}/$uid");
      final response =
          await http.post(Uri.parse("${AppStrings.getMenuItemEndpoint}/$uid")
              // .replace(
              //   queryParameters: {
              //     if (category != null) 'category': category,
              //     if (subCategory != null) 'subCategory': subCategory,
              //   },
              // ),
              );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        // Debugging: Identify the type of response based on provided parameters
        // if (category == null && subCategory == null) {
        print("Parsing as FullMenuModel...");
        final menu = {};
        for (var category in jsonResponse['menuItems']) {
          final temp = {};
          for (var subCategory in category['subCategory']) {
            temp[subCategory['subCategoryName']] = subCategory['menuItems'];
          }
          menu[category['category']] = temp;
        }
        print(menu);
        return Right(menu);
        // } else if (category != null && subCategory == null) {
        //   print("Parsing as CategoryMenuModel...");
        //   final menuModel = CategoryMenuModel.fromJson(jsonResponse);
        //   print("Parsed CategoryMenuModel: $menuModel");
        //   return Right(menuModel);
        // } else {
        //   print("Parsing as SimpleMenuModel...");
        //   final menuModel = SimpleMenuModel.fromJson(jsonResponse);
        //   print("Parsed SimpleMenuModel: $menuModel");
        //   return Right(menuModel);
        // }
      } else if (response.statusCode == 404) {
        return Left(json.decode(response.body)['message']);
      } else {
        return Left(AppStrings.failedToLoadMenuItems);
      }
    } catch (e) {
      print("Error: $e");
      print("I don't know why this error is coming");
      return Left(AppStrings.serverError);
    }
  }

  static Future<void> saveMenuItem({
    required SaveMenuItem saveMenuItem,
    required BuildContext context,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('$baseURL/menu/saveMenuItem'),
        headers: <String, String>{
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: jsonEncode(saveMenuItem.toJson()),
      );
      print(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Successfully created
        final jsonResponse = json.decode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
      } else {
        // Handle errors
        final jsonResponse = json.decode(response.body);
        Toast.showToast(message: '${jsonResponse['error']}', isError: true);
      }
    } catch (e) {
      //context.showSnackBar(message: AppStrings.serverError);
    }
  }

  static Future<bool> updateMenuItem({
    required String uid,
    required String category,
    required String subCategory,
    required String menuitemid,
    required UpdateMenuItemModel updateMenuItemModel,
    required BuildContext context,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
            "${AppStrings.updateMenuItemEndpoint}/$uid/$category/$subCategory/$menuitemid"),
        headers: {AppStrings.contentType: AppStrings.applicationJson},
        body: json.encode(updateMenuItemModel.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        context.showSuccessSnackBar(message: jsonResponse['message']);
        return true;
      } else if (response.statusCode == 404) {
        final jsonResponse = json.decode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
        return false;
      } else {
        Toast.showToast(
            message: '${AppStrings.failedToUpdateMenuItem}', isError: true);
        return false;
      }
    } catch (e) {
      //context.showSnackBar(message: AppStrings.serverError);
      return false;
    }
  }

  static Future<bool> deleteMenuItem({
    required BuildContext context,
    required String uid,
    required String category,
    required String subCategory,
    required String menuitemid,
  }) async {
    try {
      print(
          "${AppStrings.deleteMenuItemEndpoint}$uid/$category/$subCategory/$menuitemid");
      final response = await http.post(
        Uri.parse(
            "${AppStrings.deleteMenuItemEndpoint}/$uid/$category/$subCategory/$menuitemid"),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
        return true;
      } else if (response.statusCode == 404) {
        final jsonResponse = json.decode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
        return false;
      } else {
        Toast.showToast(
            message: '${AppStrings.failedToDeleteMenuItem}', isError: true);
        return false;
      }
    } catch (e) {
      // context.showSnackBar(message: AppStrings.serverError);
      return false;
    }
  }

  static Future<List<String>> fetchAllCategories({
    required String uid,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu/fetchAllCategories'),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: json.encode({'uid': uid}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final categories = List<String>.from(jsonResponse['categories']);
        return categories;
      } else {
        throw Exception(AppStrings.failedToFetchCategories);
      }
    } catch (e) {
      throw Exception(AppStrings.serverError);
    }
  }

  static Future<bool> addSubCategory({
    required String uid,
    required String category,
    required String subCategory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu/addSubCategory'),
        headers: {
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: json.encode({
          'uid': uid,
          'category': category,
          'subCategory': subCategory,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
        return true;
      } else {
        final jsonResponse = json.decode(response.body);
        Toast.showToast(message: '${jsonResponse['error']}', isError: true);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> deleteSubCategory({
    required String uid,
    required String category,
    required String subCategory,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/menu/deleteSubCategory'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'uid': uid,
          'category': category,
          'subCategory': subCategory,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
      } else {
        final jsonResponse = jsonDecode(response.body);
        Toast.showToast(message: '${jsonResponse['error']}', isError: true);
      }
    } catch (e) {
      Toast.showToast(message: 'Something went wrong !!.', isError: true);
    }
  }

  // categories API ---------------------------------------------

  static Future<bool> addCategory({
    required String uid,
    required String url,
    required String category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu/addCategory'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'uid': uid,
          'category': category,
          'url': url,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
        return true;
      } else {
        final jsonResponse = jsonDecode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}', isError: true);
        return false;
      }
    } catch (e) {
      Toast.showToast(message: 'Something went wrong ..!!', isError: true);
      return false;
    }
  }

  static Future<void> deleteCategory({
    required String uid,
    required String category,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu/deleteCategory'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'uid': uid,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        Toast.showToast(message: '${jsonResponse['message']}');
      } else {
        final jsonResponse = jsonDecode(response.body);
        Toast.showToast(message: '${jsonResponse['error']}', isError: true);
      }
    } catch (e) {
      Toast.showToast(message: 'Something went wrong ..!!', isError: true);
    }
  }

  static Future<List<String>> fetchAllSubCategories({
    required String uid,
    required String category,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/menu/fetchAllSubCategories'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'uid': uid,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        List<String> subCategories =
            List<String>.from(responseData['subCategories']);
        return subCategories;
      } else {
        throw Exception('Failed to load sub-categories');
      }
    } catch (e) {
      print('Error fetching sub-categories: $e');
      throw Exception('Failed to load sub-categories');
    }
  }

  static double getAveragePrepTime(Map menu, {double? initialTime}) {
    int itemCount = initialTime == null ? 0 : 1;
    num totaltime = initialTime ?? 0;
    for (String category in menu.keys) {
      final subCat = menu[category];
      for (String subCategory in subCat.keys) {
        for (var item in subCat[subCategory]) {
          totaltime += item['timeToPrepare'];
          itemCount++;
        }
      }
    }
    return (totaltime / itemCount).roundOff();
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';
import 'package:restaurant_app/Screens/User/banned_screen.dart';
import 'package:restaurant_app/Screens/User/login_screen.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalController {
  Future<Map<String, dynamic>?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoString = prefs.getString('user_info');
    if (userInfoString != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoString);
      return userInfo;
      // return jsonDecode(userInfoString) as Map<String, dynamic>;
    } else {
      return null;
    }
  }
}

class SignUpController {
  Future<Map<String, dynamic>> signUp([reqData]) async {
    // var baseUrl = dotenv.env['BASE_URL'];
    var baseUrl = AppStrings.baseURL;
    print('request data $reqData');
    // var request = http.MultipartRequest(
    //   'POST',
    //   Uri.parse('$baseUrl/account/updateUserAPIView/$userId'),
    // );
    // request.fields['email'] = email;
    // request.fields['name'] = name;
    // request.fields['gender'] = gender;
    // request.fields['dath_of_birth'] = formattedDate;

    // var streamedResponse = await request.send();

    // var response = await http.Response.fromStream(streamedResponse);
    final response =
        await http.post(Uri.parse('$baseUrl/auth/signup'), body: reqData);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      return data;
    } else {
      // return "Failed to Update profile";

      throw Exception('Failed to signup');
    }
  }
}

class SignInController {
  Future<dynamic> signIn() async {
    // var baseUrl = dotenv.env['BASE_URL'];
    var baseUrl = AppStrings.baseURL;
    final response = await http.get(Uri.parse('$baseUrl/auth/login/'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // print("My datadddddddddddd: $data");
      return data;
      // return Profile.fromJson(data);
    } else {
      throw Exception('Failed to login');
    }
  }
}

class LoginController {
  static Future<void> login({
    required String phoneNumber,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse(AppStrings.loginEndpoint),
        headers: <String, String>{
          AppStrings.contentType: AppStrings.applicationJson,
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': 'nopassword',
        }),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['executed'] == true) {
          await SharedPrefsUtil()
              .setString(AppStrings.userId, jsonResponse['uid'])
              .then((value) {
            Toast.showToast(message: '${jsonResponse['message']}');
            // context.push(HomeScreen());
          });
        } else {}
      } else {
        Toast.showToast(message: AppStrings.loginError, isError: true);
      }
    } catch (e) {
      // context.showSnackBar(message: AppStrings.serverError);
    }
  }

  static Future<bool> getRestaurantByID({
    required String uid,
    required BuildContext? context,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('${AppStrings.getRestaurantByIDEndpoint}/$uid'),
        headers: <String, String>{
          AppStrings.contentType: AppStrings.applicationJson,
        },
      );

      final jsonResponse = json.decode(response.body);
      print(jsonResponse); // Debugging purposes
      print('get res by id${response.statusCode}');
      if (response.statusCode == 200) {
        if (jsonResponse['user']['isBanned'] == true && context != null) {
          Navigator.of(context).pushAndRemoveUntil(
              transitionToNextScreen(const BannedScreen()), (_) => false);
          return false;
        }
        RestaurantModel model = RestaurantModel.fromJson(jsonResponse);
        await SharedPrefsUtil().setString(
          AppStrings.restaurantModel,
          jsonEncode(model.toJson()), // Serialize RestaurantModel to JSON
        );
        print('saved details');
        if (model.executed ?? false) {
          String? timeToPrepare = model.user!.timetoprepare;
          if (timeToPrepare != null) {
            await SharedPrefsUtil().setString(
              AppStrings.timeToPrepare,
              timeToPrepare,
            );
            return true; // Successfully saved timeToPrepare
          } else {
            await SharedPrefsUtil().setString(
              AppStrings.timeToPrepare,
              "0.00",
            );
            return false;
          }
        } else {
          if (context != null) {
            SharedPrefsUtil().remove(AppStrings.userId);
            SharedPrefsUtil().remove(AppStrings.userInfo);
            Navigator.of(context).pushAndRemoveUntil(
                transitionToNextScreen(const Login_Screen()),
                (route) => route.isFirst);
          }
          return false; // API execution failed
        }
      } else {
        if (context != null) {}
        return false; // Non-200 status code
      }
    } on http.ClientException {
      Toast.showToast(message: 'No Internet', isError: true);
      return false; // Exception occurred
    }
  }

  static Future<bool> updateRestaurantByIDtimetoprepare({
    required String uid,
    required String timeToPrepare,
    required BuildContext? context,
  }) async {
    print(AppStrings.updateRestaurantByIdEndpoint);

    // Construct the updateData map as expected by the server
    Map<String, dynamic> updateData = {
      "_id": uid,
      "updateData": {
        "timetoprepare": timeToPrepare,
      }
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(AppStrings.updateRestaurantByIdEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updateData),
      );

      final jsonResponse = json.decode(response.body);
      print(jsonResponse); // Debugging purposes

      if (response.statusCode == 200) {
        // Example response handling
        await SharedPrefsUtil().setString(
          AppStrings.timeToPrepare,
          timeToPrepare,
        );
        return true; // Successfully updated and saved timeToPrepare
      } else {
        return false; // Non-200 status code
      }
    } catch (e) {
      print(e.toString()); // Print the exception for debugging
      // context.showSnackBar(message: AppStrings.serverError);
      return false; // Exception occurred
    }
  }

  static Future<bool> updateRestaurantByIDOperationalhours({
    required String uid,
    required Map<String, dynamic> operationalHours,
    required BuildContext context,
  }) async {
    print(AppStrings.updateRestaurantByIdEndpoint);
    // Construct the updateData map as expected by the server
    Map<String, dynamic> updateData = {
      "_id": uid,
      "updateData": {
        "operationalHours": operationalHours,
      }
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(AppStrings.updateRestaurantByIdEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updateData),
      );

      final jsonResponse = json.decode(response.body);
      print(jsonResponse); // Debugging purposes

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Example response handling
        Toast.showToast(message: 'Timings Updated Successfully');
        return true; // Successfully updated and saved timeToPrepare
      } else {
        return false; // Non-200 status code
      }
    } catch (e) {
      print(e.toString()); // Print the exception for debugging
      // context.showSnackBar(message: AppStrings.serverError);
      return false; // Exception occurred
    }
  }

  static Future<bool> updateRestaurantDataByID(
      {required String uid,
      required Map<String, dynamic> data,
      required BuildContext context,
      bool showToast = true}) async {
    print(AppStrings.updateRestaurantByIdEndpoint);
    // Construct the updateData map as expected by the server
    Map<String, dynamic> updateData = {"_id": uid, "updateData": data};

    try {
      final http.Response response = await http.post(
        Uri.parse(AppStrings.updateRestaurantByIdEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updateData),
      );

      final jsonResponse = json.decode(response.body);
      print(jsonResponse); // Debugging purposes

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Example response handling
        if (showToast) {
          Toast.showToast(message: 'Profile Updated Successfully');
        }
        return true; // Successfully updated and saved timeToPrepare
      } else {
        return false; // Non-200 status code
      }
    } catch (e) {
      print(e.toString()); // Print the exception for debugging
      // context.showSnackBar(message: AppStrings.serverError);
      return false; // Exception occurred
    }
  }

  static Future<bool> updateRestaurantpicture({
    required String uid,
    required String imageurl,
    required BuildContext context,
  }) async {
    print(AppStrings.updateRestaurantByIdEndpoint);
    // Construct the updateData map as expected by the server
    Map<String, dynamic> updateData = {
      "_id": uid,
      "updateData": {
        "restaurantImages": [imageurl],
      }
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(AppStrings.updateRestaurantByIdEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updateData),
      );

      final jsonResponse = json.decode(response.body);
      print(jsonResponse); // Debugging purposes

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Example response handling
        Navigator.of(context).pop();
        Toast.showToast(message: 'Image Updated Successfully');
        return true; // Successfully updated and saved timeToPrepare
      } else {
        return false; // Non-200 status code
      }
    } catch (e) {
      print(e.toString()); // Print the exception for debugging
      // context.showSnackBar(message: AppStrings.serverError);
      return false; // Exception occurred
    }
  }

  static Future<void> updateIsOpen(
      {required String uid, required bool isOpen}) async {
    final response = await http.post(
      Uri.parse(AppStrings.updateRestaurantByIdEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "_id": uid,
        "updateData": {"isOpen": isOpen}
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Unable to update status, please try again");
    }
  }
}

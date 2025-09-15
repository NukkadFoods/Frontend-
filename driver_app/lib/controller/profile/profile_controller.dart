import 'dart:convert';

import 'package:driver_app/widgets/constants/strings.dart';
import 'package:http/http.dart' as http;
// import 'package:restaurant_app/Widgets/constants/navigation_extension.dart';
// import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
// import 'package:restaurant_app/Widgets/constants/show_snack_bar_extension.dart';
// import 'package:restaurant_app/Widgets/constants/strings.dart';
// import 'package:restaurant_app/homeScreen.dart';
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
    String baseUrl = AppStrings.baseURL;
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

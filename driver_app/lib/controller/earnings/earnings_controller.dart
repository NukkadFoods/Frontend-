import 'dart:convert';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:http/http.dart' as http;

class EarningsController {
  // static String endpoint = "${dotenv.env["BASE_URL"]!}/earnings";
  static String endpoint = "${AppStrings.baseURL}/earnings";
  static const Map<String, String> _headers = {
    "Content-Type": "application/json"
  };
  static Future<bool> createEarning(String uid) async {
    try {
      final response = await http.post(Uri.parse("$endpoint/createEarning"),
          headers: _headers,
          body: jsonEncode({
            "earnedById": uid,
            "earnings": [
              {
                "orderId": "Welcome",
                "userId": "Welcome",
                "status": "completed",
                "amount": 0
              }
            ]
          }));
      if (response.statusCode == 201) {
        final deletionResponse = await http
            .delete(Uri.parse("$endpoint/deleteEarning/$uid/Welcome"));
        if (deletionResponse.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: "No Internet", isError: true);
      }
      return false;
    }
  }

  static Future<bool> addEarning(
      {required String uid,
      required String orderId,
      required String userId,
      required double amount}) async {
    try {
      final deletionResponse =
          await http.delete(Uri.parse("$endpoint/deleteEarning/$uid/$orderId"));
      if (!(deletionResponse.statusCode == 200 ||
          deletionResponse.statusCode == 404)) {
        throw Exception("Server Error");
      }
      final response = await http.post(Uri.parse("$endpoint/addEarnings"),
          headers: _headers,
          body: jsonEncode({
            "earnedById": uid,
            "newEarnings": [
              {
                "orderId": orderId,
                "userId": userId,
                "status": amount == 0 ? "completed" : "pending",
                "amount": amount
              }
            ]
          }));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Toast.showToast(
          message: e is http.ClientException
              ? "No Internet"
              : "Something went wrong",
          isError: true);
      print(e);
      return false;
    }
  }

  static Future<bool> updateEarning(
      {required String uid,
      required String earningId,
      required String newStatus,
      double? amount}) async {
    final requestBody = <String, dynamic>{
      "earnedById": uid,
      "earningId": earningId,
      "updatedData": <String, dynamic>{
        "status": newStatus, // optional fields: status, amount, etc.
      }
    };
    if (amount != null) {
      requestBody['updatedData']['amount'] = amount;
    }
    print(requestBody);
    try {
      final response = await http.put(Uri.parse("$endpoint/updateEarning"),
          headers: _headers, body: jsonEncode(requestBody));
      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.body);
        return false;
      }
    } catch (e) {
      Toast.showToast(
          message: e is http.ClientException
              ? "No Internet"
              : "Something went wrong",
          isError: true);
      print(e);
      return false;
    }
  }

  /// Wrap inside try catch may throw ClientException and check for "error" key to check whether there is error in server's response or not
  static Future getEarnings({required String uid}) async {
    final response = await http.get(Uri.parse("$endpoint/getEarnings/$uid"));
    return jsonDecode(response.body);
  }

  /// Wrap inside try catch may throw ClientException and check for "error" key to check whether there is error in server's response or not
  static Future getEarningsByStatus(
      {required uid, required String status}) async {
    final response =
        await http.get(Uri.parse("$endpoint/getEarnings/$uid/$status"));
    return jsonDecode(response.body);
  }
}

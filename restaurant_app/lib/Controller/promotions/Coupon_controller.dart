// controllers/coupon_controller.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/Controller/promotions/Coupon_model.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/toast.dart';

class CouponController {
  CouponController._();
  static final String apiUrl =
      '${AppStrings.baseURL}/coupon'; // Replace with your base URL

  static Future<bool> createCoupon(Coupon coupon) async {
    final url = Uri.parse('$apiUrl/createCoupon');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(coupon.toJson()),
      );

      if (response.statusCode == 201) {
        // Coupon created successfully
        return true;
      } else {
        // Handle error response
        print('Failed to create coupon: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error creating coupon: $error');
      return false;
    }
  }

  static Future<bool> updateCoupon(Coupon coupon) async {
    final url = Uri.parse('$apiUrl/updateCoupon/${coupon.couponCode}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(coupon.toJson()),
      );

      if (jsonDecode(response.body)['status'] == 'success') {
        // Coupon created successfully
        return true;
      } else {
        // Handle error response
        print('Failed to create coupon: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error creating coupon: $error');
      return false;
    }
  }

  static Future<CouponsResponse?> getAllCouponsByCreatedById(
      String createdById) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppStrings.baseURL}/coupon/getAllCouponsByCreatedById/$createdById'),
        headers: {'Content-Type': 'application/json'},
      );
      print('getAllCouponsByCreatedById response code: ${response.statusCode}');
      print('getAllCouponsByCreatedById response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CouponsResponse.fromJson(data);
      }
      return null; // Return null if the status code is not 200
    } catch (e) {
      print('Error occurred while fetching coupons: $e');
      return null; // Return null in case of error
    }
  }

  static Future<void> updateCouponStatus(
    String couponCode,
    String status,
  ) async {
    final url = Uri.parse('${AppStrings.baseURL}/coupon/updateCouponStatus');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'couponCode': couponCode,
      'status': status,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Coupon status updated successfully.');
      } else {
        print(
            'Failed to update coupon status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while updating coupon status: $e');
    }
  }

  static Future<void> deleteCoupon(String couponCode) async {
    final url = '${AppStrings.baseURL}/coupon/deleteCoupon/$couponCode';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        Toast.showToast(message: 'Coupon Deleted Successfully ..!');
        print(responseData['message']);
        // Handle the success message here
      } else {
        print('Failed to delete the coupon');
        Toast.showToast(message: 'Failed to delete..!', isError: true);
      }
    } catch (error) {
      print('Error occurred while deleting the coupon: $error');
    }
  }
}

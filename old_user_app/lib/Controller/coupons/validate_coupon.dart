import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/widgets/constants/strings.dart';
// Make sure to include your AppStrings if needed

class CouponValidationController {
  static Future<ValidateCouponResponse?> validateCoupon(
      String couponCode, double orderValue) async {
    try {
      final response = await http.post(
        Uri.parse('${AppStrings.baseURL}/coupon/validateCoupon'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'couponCode': couponCode,
          'orderValue': orderValue,
        }),
      );

      if (kDebugMode) {
        print({
          'couponCode': couponCode,
          'orderValue': orderValue,
        });
        print('validateCoupon response code: ${response.statusCode}');
        print('validateCoupon response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data'); // Debugging line to inspect the response
        return ValidateCouponResponse.fromJson(data);
      }
      return null; // Return null if the status code is not 200
    } catch (e) {
      print('Error occurred while validating coupon: $e');
      return null; // Return null in case of error
    }
  }
}

class ValidateCouponResponse {
  final bool isValid; // To indicate if the coupon is valid
  final String message; // Message from the API
  final double discountApplied; // Discount value applied to the order
  final double
      finalPrice; // This could be calculated based on the order value after discount

  ValidateCouponResponse({
    required this.isValid,
    required this.message,
    required this.discountApplied,
    required this.finalPrice,
  });

  factory ValidateCouponResponse.fromJson(Map<String, dynamic> json) {
    num discount = json['discount'] ?? 0; // Default to 0 if null
    bool isValid =
        json['status'] == 'success'; // Determine validity based on status
    return ValidateCouponResponse(
      isValid: isValid,
      message:
          json['message'] ?? 'No message provided', // Default message if null
      discountApplied: discount.toDouble(),
      finalPrice:
          0, // You may want to calculate final price based on order value
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:user_app/Controller/coupons/couponmodel.dart';
import 'package:user_app/widgets/constants/strings.dart';

class CouponController {
  static Future<List<Coupon>> getAllCoupons() async {
    try {
      final response = await http
          .get(Uri.parse('${AppStrings.baseURL}/coupon/getAllCoupons'));
      print('couponget : ${response.statusCode}');
      print('couponget : ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['coupons'] != null) {
          return (data['coupons'] as List)
              .map((couponJson) => Coupon.fromJson(couponJson))
              .toList();
        }
      }
      return []; // Return an empty list if no coupons found
    } catch (e) {
      print('Error occurred while fetching coupons: $e');
      return []; // Return an empty list in case of error
    }
  }
}

class CouponResponse {
  final List<Coupon> coupons;
  final String status;

  CouponResponse({required this.coupons, required this.status});

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    var couponsList = json['coupons'] as List;
    List<Coupon> coupons =
        couponsList.map((couponJson) => Coupon.fromJson(couponJson)).toList();

    return CouponResponse(
      coupons: coupons,
      status: json['status'],
    );
  }
}

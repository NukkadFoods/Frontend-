// models/coupon_model.dart

class Coupon {
  final String createdById;
  final String couponCode;
  final int discountPercentage; // Keep as int
  final int flatRsOff;          // Keep as int
  final int minOrderValue;      // Keep as int
  final int maxDiscount;    
  final String status;

  Coupon({
    required this.createdById,
    required this.couponCode,
    required this.discountPercentage,
    required this.flatRsOff,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.status,
  });

  // Convert a Coupon object into a Map object.
  Map<String, dynamic> toJson() {
    return {
      'createdById': createdById,
      'couponCode': couponCode,
      'discountPercentage': discountPercentage,
      'flatRsOff': flatRsOff,
      'minOrderValue': minOrderValue,
      'maxDiscount': maxDiscount,
      'status': status,
    };
  }

  // Convert a Map object into a Coupon object.
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      createdById: json['createdById'],
      couponCode: json['couponCode'],
      discountPercentage: json['discountPercentage'],
      flatRsOff: json['flatRsOff'],
      minOrderValue: json['minOrderValue'],
      maxDiscount: json['maxDiscount'],
      status: json['status'],
    );
  }  
}
class CouponsResponse {
  final List<Coupon> coupons;
  final String status;

  CouponsResponse({
    required this.coupons,
    required this.status,
  });

  factory CouponsResponse.fromJson(Map<String, dynamic> json) {
    var list = json['coupons'] as List;
    List<Coupon> couponsList =
        list.map((i) => Coupon.fromJson(i)).toList();

    return CouponsResponse(
      coupons: couponsList,
      status: json['status'],
    );
  }
}

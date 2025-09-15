class Coupon {
  final String id;
  final String createdById;
  final String couponCode;
  final int discountPercentage;
  final int flatRsOff;
  final int minOrderValue;
  final int maxDiscount;
  final String status;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.createdById,
    required this.couponCode,
    required this.discountPercentage,
    required this.flatRsOff,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.status,
    required this.createdAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    // Parsing the nested 'coupon' object if it's present in the response
    if (json.containsKey('coupon')) {
      json = json['coupon'];
    }

    return Coupon(
      id: json['_id'],
      createdById: json['createdById'],
      couponCode: json['couponCode'],
      discountPercentage: json['discountPercentage'] ?? 0,
      flatRsOff: json['flatRsOff'] ?? 0,
      minOrderValue: json['minOrderValue'] ?? 0,
      maxDiscount: json['maxDiscount'] ?? 0,
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

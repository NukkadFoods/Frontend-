import 'package:restaurant_app/Controller/order/orders_model.dart';

class OrderModel {
  OrderModel({
    this.order,
  });

  OrderModel.fromJson(dynamic json) {
    order = json['order'] != null ? Orders.fromJson(json['order']) : null;
  }
  Orders? order;
  OrderModel copyWith({
    Orders? order,
  }) =>
      OrderModel(
        order: order ?? this.order,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (order != null) {
      map['order'] = order?.toJson();
    }
    return map;
  }
}

import 'package:user_app/Controller/order/orders_model.dart';

class UpdateOrderResponseModel {
  UpdateOrderResponseModel({
    this.message,
    this.order,
  });

  UpdateOrderResponseModel.fromJson(dynamic json) {
    message = json['message'];
    order = json['order'] != null ? Orders.fromJson(json['order']) : null;
  }
  String? message;
  Orders? order;
  UpdateOrderResponseModel copyWith({
    String? message,
    Orders? order,
  }) =>
      UpdateOrderResponseModel(
        message: message ?? this.message,
        order: order ?? this.order,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (order != null) {
      map['order'] = order?.toJson();
    }
    return map;
  }
}

// class OrdersModel {
//   OrdersModel({
//     this.orders,
//   });

//   OrdersModel.fromJson(dynamic json) {
//     if (json['orders'] != null) {
//       orders = [];
//       json['orders'].forEach((v) {
//         if (v['Restaurantuid'] ==
//             SharedPrefsUtil().getString(
//                 AppStrings.userId)) //filtering orders for this restaurant only
//         {
//           orders!.add(Orders.fromJson(v));
//         }
//       });
//     }
//   }
//   List<Orders>? orders;
//   OrdersModel copyWith({
//     List<Orders>? orders,
//   }) =>
//       OrdersModel(
//         orders: orders ?? this.orders,
//       );
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (orders != null) {
//       map['orders'] = orders?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }

//   // Method to group orders by status and return a map
//   Map<String, List<Orders>> groupOrdersByStatus() {
//     Map<String, List<Orders>> groupedOrders = {};
//     if (orders != null) {
//       for (var order in orders!) {
//         if (order.orderData != null) {
//           if (groupedOrders.containsKey(order.orderData!.status)) {
//             groupedOrders[order.orderData!.status]?.add(order);
//           } else {
//             groupedOrders[order.orderData!.status!] = [order];
//           }
//         }
//       }
//     }
//     return groupedOrders;
//   }
// }

// class Orders {
//   String? uid;
//   OrderData? orderData;

//   Orders({this.uid, this.orderData});

//   Orders.fromJson(Map<String, dynamic> json) {
//     uid = json['uid'];
//     orderData = OrderData.fromJson(json);
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['uid'] = uid;
//     if (orderData != null) {
//       data['orderData'] = orderData!.toJson();
//     }
//     return data;
//   }
// }

import 'dart:async';

class OrderData {
  String? orderId;
  String? restaurantuid;
  String? cookingDescription;
  double? drivertip;
  String? couponcode;
  String? date;
  String? time;
  String? paymentMethod;
  double? totalCost;
  double? gst;
  double? itemAmount;
  double? deliveryCharge;
  double? convinenceFee;
  String? orderByid;
  String? orderByName;
  String? status;
  String? deliveryAddress;
  List<Items>? items;
  bool? accepted;
  int? totalItems;
  String? timetoprepare;
  Map? billingDetail;
  String? hubId;

  OrderData(
      {this.orderId,
      this.restaurantuid,
      this.cookingDescription,
      this.drivertip,
      this.couponcode,
      this.date,
      this.time,
      this.paymentMethod,
      this.totalCost,
      this.gst,
      this.itemAmount,
      this.deliveryCharge,
      this.convinenceFee,
      this.orderByid,
      this.orderByName,
      this.status,
      this.deliveryAddress,
      this.items,
      this.accepted,
      this.timetoprepare,
      this.totalItems,
      this.billingDetail,
      this.hubId});

  OrderData.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    restaurantuid = json['Restaurantuid'];
    cookingDescription = json['cookingDescription'];
    drivertip = double.tryParse(json['drivertip'].toString());
    couponcode = json['couponcode'];
    date = json['date'];
    time = json['time'];
    paymentMethod = json['paymentMethod'];
    totalCost = double.tryParse(json['totalCost'].toString());
    gst = json['gst'];
    itemAmount = double.tryParse(json['itemAmount'].toString());
    deliveryCharge = double.tryParse(json['deliveryCharge'].toString());
    convinenceFee = double.tryParse(json['convinenceFee'].toString());
    orderByid = json['orderByid'];
    orderByName = json['orderByName'];
    status = json['status'];
    deliveryAddress = json['deliveryAddress'];
    accepted = json['accepted'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    timetoprepare = json['timetoprepare'];
    billingDetail = json['billingDetail'];
    totalItems = getTotalItems(items!);
  }
  int getTotalItems(List<Items> items) {
    int itemCount = 0;
    for (Items item in items) {
      itemCount += item.itemQuantity!;
    }
    return itemCount;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['accepted'] = accepted;
    data['Restaurantuid'] = restaurantuid;
    data['cookingDescription'] = cookingDescription;
    data['drivertip'] = drivertip;
    data['couponcode'] = couponcode;
    data['date'] = date;
    data['time'] = time;
    data['paymentMethod'] = paymentMethod;
    data['totalCost'] = totalCost;
    data['gst'] = gst;
    data['itemAmount'] = itemAmount;
    data['deliveryCharge'] = deliveryCharge;
    data['convinenceFee'] = convinenceFee;
    data['orderByid'] = orderByid;
    data['orderByName'] = orderByName;
    data['status'] = status;
    data['deliveryAddress'] = deliveryAddress;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['timetoprepare'] = timetoprepare;
    data['billingDetail'] = billingDetail;
    return data;
  }
}

class Items {
  String? itemId;
  String? itemName;
  int? itemQuantity;
  int? unitCost;

  Items({this.itemId, this.itemName, this.itemQuantity, this.unitCost});

  Items.fromJson(Map<String, dynamic> json) {
    itemId = json['itemId'];
    itemName = json['itemName'];
    itemQuantity = json['itemQuantity'];
    unitCost = json['unitCost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['itemId'] = itemId;
    data['itemName'] = itemName;
    data['itemQuantity'] = itemQuantity;
    data['unitCost'] = unitCost;
    return data;
  }
}

class Restaurant {
  String? nukkadName;
  String? nukkadAddress;
  double? latitude;
  double? longitude;
  String? phoneNumber;
  String? image;

  Restaurant(
      {this.nukkadName,
      this.nukkadAddress,
      this.latitude,
      this.longitude,
      this.phoneNumber,
      this.image});

  Restaurant.fromJson(Map<String, dynamic> json) {
    nukkadName = json['nukkadName'];
    nukkadAddress = json['nukkadAddress'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    phoneNumber = json['phoneNumber'];
    if (json['restaurantImages'] != null &&
        json['restaurantImages'].isNotEmpty) {
      image = json['restaurantImages'][0];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nukkadName'] = nukkadName;
    data['nukkadAddress'] = nukkadAddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['phoneNumber'] = phoneNumber;
    if (image != null) {
      data['restaurantImages'] = image;
    }
    return data;
  }
}

class CountDown {
  CountDown(this.secondsRemaining, this.totalSeconds) {
    stream = Stream.periodic(const Duration(seconds: 1), (_) {
      return secondsRemaining--;
    }).asBroadcastStream();
  }
  int secondsRemaining;
  double value = 0;
  int totalSeconds;
  late Stream<int> stream;
}

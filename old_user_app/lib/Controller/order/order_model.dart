class OrderModel {
  final String uid;
  final OrderData orderData;

  OrderModel({required this.uid, required this.orderData});

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'orderData': orderData.toJson(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      uid: json['uid'],
      orderData: OrderData.fromJson(json['orderData']),
    );
  }
}

class OrderData {
  final String orderId;
  final String Restaurantuid;
  final String cookingDescription;
  final double drivertip;
  final String couponcode;
  final String date; // Format as ISO8601 string
  final String time;
  final String paymentMethod;
  final double totalCost;
  final double gst;
  final double itemAmount; // Ensure this is an int
  final double deliveryCharge;
  final double convinenceFee;
  final String orderByid;
  final String orderByName;
  final String status;
  final String deliveryAddress;
  final List<OrderItem> items;
  final String timetoprepare;
  final String ordertype;
  final Map billingDetails;
  OrderData(
      {required this.orderId,
      required this.Restaurantuid,
      required this.cookingDescription,
      required this.drivertip,
      required this.couponcode,
      required this.date,
      required this.time,
      required this.paymentMethod,
      required this.totalCost,
      required this.gst,
      required this.itemAmount,
      required this.deliveryCharge,
      required this.convinenceFee,
      required this.orderByid,
      required this.orderByName,
      required this.status,
      required this.deliveryAddress,
      required this.items,
      required this.timetoprepare,
      required this.ordertype,
      required this.billingDetails});

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'Restaurantuid': Restaurantuid,
      'cookingDescription': cookingDescription,
      'drivertip': drivertip,
      'couponcode': couponcode,
      'date': date,
      'time': time,
      'paymentMethod': paymentMethod,
      'totalCost': totalCost,
      'gst': gst,
      'itemAmount': itemAmount,
      'deliveryCharge': deliveryCharge,
      'convinenceFee': convinenceFee,
      'orderByid': orderByid,
      'orderByName': orderByName,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'timetoprepare': timetoprepare,
      'ordertype': ordertype,
      'billingDetail': billingDetails
    };
  }

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
        orderId: json['orderId'],
        Restaurantuid: json['Restaurantuid'],
        cookingDescription: json['cookingDescription'],
        drivertip: json['drivertip'],
        couponcode: json['couponcode'],
        date: json['date'],
        time: json['time'],
        paymentMethod: json['paymentMethod'],
        totalCost: json['totalCost'],
        gst: json['gst'],
        itemAmount: json['itemAmount'],
        deliveryCharge: json['deliveryCharge'],
        convinenceFee: json['convinenceFee'],
        orderByid: json['orderByid'],
        orderByName: json['orderByName'],
        status: json['status'],
        deliveryAddress: json['deliveryAddress'],
        items: List<OrderItem>.from(
            json['items'].map((item) => OrderItem.fromJson(item))),
        timetoprepare: json['timetoprepare'],
        ordertype: json['ordertype'],
        billingDetails: json['billingDetail']);
  }
}

class OrderItem {
  final String itemId;
  final String itemName;
  final int itemQuantity; // Ensure this is an int
  final double unitCost;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.itemQuantity,
    required this.unitCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemQuantity': itemQuantity,
      'unitCost': unitCost,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'],
      itemName: json['itemName'],
      itemQuantity: json['itemQuantity'],
      unitCost: json['unitCost'],
    );
  }
}

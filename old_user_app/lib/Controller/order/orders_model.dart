class OrdersModel {
  OrdersModel({
    this.orders,
  });

  OrdersModel.fromJson(dynamic json) {
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders?.add(Orders.fromJson(v));
      });
    }
  }
  List<Orders>? orders;
  OrdersModel copyWith({
    List<Orders>? orders,
  }) =>
      OrdersModel(
        orders: orders ?? this.orders,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (orders != null) {
      map['orders'] = orders?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  // Method to group orders by status and return a map
  Map<String, List<Orders>> groupOrdersByStatus() {
    Map<String, List<Orders>> groupedOrders = {};
    if (orders != null) {
      for (var order in orders!) {
        if (groupedOrders.containsKey(order.status)) {
          groupedOrders[order.status]?.add(order);
        } else {
          groupedOrders[order.status!] = [order];
        }
      }
    }
    return groupedOrders;
  }
}

class Orders {
  Orders(
      {this.orderId,
      this.Restaurantuid,
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
      this.id,
      this.billingDetail});

  Orders.fromJson(dynamic json) {
    orderId = json['orderId'];
    Restaurantuid = json['Restaurantuid'];
    date = json['date'];
    time = json['time'];
    paymentMethod = json['paymentMethod'];
    totalCost = json['totalCost'];
    gst = json['gst'];
    itemAmount = json['itemAmount'];
    deliveryCharge = json['deliveryCharge'];
    convinenceFee = json['convinenceFee'];
    orderByid = json['orderByid'];
    orderByName = json['orderByName'];
    status = json['status'];
    deliveryAddress = json['deliveryAddress'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
    id = json['_id'];
    timetoprepare = json['timetoprepare'];
    ordertype = json['ordertype'];
    billingDetail = json['billingDetail'];
  }
  String? orderId;
  String? Restaurantuid;
  String? date;
  String? time;
  String? paymentMethod;
  num? totalCost;
  num? gst;
  num? itemAmount;
  num? deliveryCharge;
  num? convinenceFee;
  String? orderByid;
  String? orderByName;
  String? status;
  String? deliveryAddress;
  List<Items>? items;
  String? id;
  String? timetoprepare;
  String? ordertype;
  Map? billingDetail;
  Orders copyWith({
    String? orderId,
    String? Restaurantuid,
    String? date,
    String? time,
    String? paymentMethod,
    num? totalCost,
    num? gst,
    num? itemAmount,
    num? deliveryCharge,
    num? convinenceFee,
    String? orderByid,
    String? orderByName,
    String? status,
    String? deliveryAddress,
    List<Items>? items,
    String? id,
    String? uid,
    String? timetoprepare,
    String? ordertype,
  }) =>
      Orders(
        orderId: orderId ?? this.orderId,
        Restaurantuid: Restaurantuid ?? this.Restaurantuid,
        date: date ?? this.date,
        time: time ?? this.time,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        totalCost: totalCost ?? this.totalCost,
        gst: gst ?? this.gst,
        itemAmount: itemAmount ?? this.itemAmount,
        deliveryCharge: deliveryCharge ?? this.deliveryCharge,
        convinenceFee: convinenceFee ?? this.convinenceFee,
        orderByid: orderByid ?? this.orderByid,
        orderByName: orderByName ?? this.orderByName,
        status: status ?? this.status,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        items: items ?? this.items,
        id: id ?? this.id,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['orderId'] = orderId;
    map['Restaurantuid'] = Restaurantuid;
    map['date'] = date;
    map['time'] = time;
    map['paymentMethod'] = paymentMethod;
    map['totalCost'] = totalCost;
    map['gst'] = gst;
    map['itemAmount'] = itemAmount;
    map['deliveryCharge'] = deliveryCharge;
    map['convinenceFee'] = convinenceFee;
    map['orderByid'] = orderByid;
    map['orderByName'] = orderByName;
    map['status'] = status;
    map['deliveryAddress'] = deliveryAddress;
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    map['_id'] = id;
    map['timetoprepare'] = timetoprepare;
    map['ordertype'] = ordertype;
    map['billingDetail'] = billingDetail;
    return map;
  }
}

class Items {
  Items({
    this.itemId,
    this.itemName,
    this.itemQuantity,
    this.unitCost,
    this.id,
  });

  Items.fromJson(dynamic json) {
    itemId = json['itemId'];
    itemName = json['itemName'];
    itemQuantity = json['itemQuantity'];
    unitCost = json['unitCost'];
    id = json['_id'];
  }
  String? itemId;
  String? itemName;
  num? itemQuantity;
  num? unitCost;
  String? id;
  Items copyWith({
    String? itemId,
    String? itemName,
    num? itemQuantity,
    num? unitCost,
    String? id,
  }) =>
      Items(
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        itemQuantity: itemQuantity ?? this.itemQuantity,
        unitCost: unitCost ?? this.unitCost,
        id: id ?? this.id,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['itemId'] = itemId;
    map['itemName'] = itemName;
    map['itemQuantity'] = itemQuantity;
    map['unitCost'] = unitCost;
    map['_id'] = id;
    return map;
  }
}

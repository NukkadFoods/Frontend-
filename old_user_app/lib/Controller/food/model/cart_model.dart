class CartModel {
  String restaurantId;
  String itemId;
  String itemName;
  int itemQuantity;
  double unitCost;
  String type;
  num timetoprepare;

  CartModel({
    required this.restaurantId,
    required this.itemId,
    required this.itemName,
    required this.itemQuantity,
    required this.unitCost,
    required this.type,
    required this.timetoprepare,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
        restaurantId: json['restaurantId'],
        itemId: json['itemId'],
        itemName: json['itemName'],
        itemQuantity: json['quantity'],
        unitCost: json['unitCost']
            .toDouble(), // Assuming unitCost is received as double
        type: json['type']??"",
        timetoprepare: json['timetoprepare']??0);
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': itemQuantity,
      'unitCost': unitCost,
      'type': type,
      'timetoprepare': timetoprepare
    };
  }

  CartModel copyWith(
      {String? restaurantId,
      String? itemId,
      String? itemName,
      int? itemQuantity,
      double? unitCost,
      String? type,
      num? timetoprepare}) {
    return CartModel(
        restaurantId: restaurantId ?? this.restaurantId,
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        itemQuantity: itemQuantity ?? this.itemQuantity,
        unitCost: unitCost ?? this.unitCost,
        type: type ?? this.type,
        timetoprepare: timetoprepare ?? this.timetoprepare);
  }
}

import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';

class UserModel {
  UserModel({
    this.message,
    this.executed,
    this.user,
  });

  UserModel.fromJson(dynamic json) {
    message = json['message'];
    executed = json['executed'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  String? message;
  bool? executed;
  User? user;

  UserModel copyWith({
    String? message,
    bool? executed,
    User? user,
  }) =>
      UserModel(
        message: message ?? this.message,
        executed: executed ?? this.executed,
        user: user ?? this.user,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['executed'] = executed;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }
}

class User {
  User(
      {this.id,
      this.username,
      this.email,
      this.contact,
      this.addresses,
      this.gender,
      this.userImage,
      this.v,
      this.cart,
      this.favoriteRestaurants,
      this.hiddenrestaurants,
      this.referredby,
      this.isBanned});

  User.fromJson(dynamic json) {
    id = json['_id'];
    username = json['username'];
    email = json['email'];
    contact = json['contact'];
    gender = json['gender'];
    userImage = json['userImage'];
    referredby = json['referredby'];
    isBanned = json['isBanned'];
    v = json['__v'];
    cart = json['cart'] != null ? _filterAndConsolidateCart(json['cart']) : [];
    favoriteRestaurants = json['favoriteRestaurants'] != null
        ? json['favoriteRestaurants'].cast<String>()
        : [];
    hiddenrestaurants = json['hiddenrestaurants'] != null
        ? (json['hiddenrestaurants'] as List)
            .map((item) => Restaurants.fromJson(item))
            .toList()
        : [];
    addresses = json['addresses'] != null
        ? List<Address>.from(json['addresses'].map((v) => Address.fromJson(v)))
        : [];
  }

  String? id;
  String? username;
  String? email;
  String? contact;
  String? gender;
  String? userImage;
  Map? referredby; // Updated to reflect Buffer type in schema
  num? v;
  List<Address>? addresses; // Updated to match schema structure
  List<CartModel>? cart;
  List<String>? favoriteRestaurants;
  List<Restaurants>? hiddenrestaurants;
  bool? isBanned;

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? contact,
    String? gender,
    String? userImage,
    String? referredby,
    num? v,
    List<Address>? addresses,
    List<CartModel>? cart,
    List<String>? favoriteRestaurants,
    List<Restaurants>? hiddenrestaurants,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        contact: contact ?? this.contact,
        gender: gender ?? this.gender,
        userImage: userImage ?? this.userImage,
        // referredby : referredby ?? this.referredby,
        v: v ?? this.v,
        addresses: addresses ?? this.addresses,
        cart: cart ?? this.cart,
        favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
        hiddenrestaurants: hiddenrestaurants ?? this.hiddenrestaurants,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['username'] = username;
    map['email'] = email;
    map['contact'] = contact;
    map['gender'] = gender;
    map['userImage'] = userImage;
    map['referredby'] = referredby;
    map['__v'] = v;
    if (addresses != null) {
      map['addresses'] = addresses
          ?.map((v) => v.toJson())
          .toList(); // Include addresses in JSON
    }
    if (cart != null) {
      map['cart'] = cart?.map((item) => item.toJson()).toList();
    }
    map['favoriteRestaurants'] = favoriteRestaurants ?? [];
    if (hiddenrestaurants != null) {
      map['hiddenrestaurants'] =
          hiddenrestaurants?.map((item) => item.toJson()).toList();
    }

    return map;
  }

  static List<CartModel> _filterAndConsolidateCart(List<dynamic> cartJson) {
    List<CartModel> cartList = [];

    for (var jsonItem in cartJson) {
      CartModel item = CartModel.fromJson(jsonItem);
      bool exists = cartList.any((existingItem) =>
          existingItem.restaurantId == item.restaurantId &&
          existingItem.itemId == item.itemId &&
          existingItem.itemName == item.itemName &&
          existingItem.unitCost == item.unitCost);

      if (!exists) {
        cartList.add(item);
      } else {
        cartList
            .firstWhere((existingItem) =>
                existingItem.restaurantId == item.restaurantId &&
                existingItem.itemId == item.itemId &&
                existingItem.itemName == item.itemName &&
                existingItem.unitCost == item.unitCost)
            .itemQuantity += item.itemQuantity;
      }
    }

    return cartList;
  }

  double getCartTotal() {
    if (cart == null) return 0.0;
    double total = 0.0;
    for (var item in cart!) {
      total += item.itemQuantity * item.unitCost;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  int getCartTotalQuantity() {
    if (cart == null) return 0;
    int totalQuantity = 0;
    for (var item in cart!) {
      totalQuantity += item.itemQuantity;
    }
    return totalQuantity;
  }

  double getCartTotalForRestaurant(String restaurantId) {
    if (cart == null) return 0.0;
    double total = 0.0;
    for (var item in cart!) {
      if (item.restaurantId == restaurantId) {
        total += item.itemQuantity * item.unitCost;
      }
    }
    return double.parse(total.toStringAsFixed(2));
  }

  int getCartTotalQuantityForRestaurant(String restaurantId) {
    if (cart == null) return 0;
    int totalQuantity = 0;
    for (var item in cart!) {
      if (item.restaurantId == restaurantId) {
        totalQuantity += item.itemQuantity;
      }
    }
    return totalQuantity;
  }
}

// Address class as per schema
class Address {
  Address({
    this.address,
    this.latitude,
    this.longitude,
    this.area,
    this.hint,
    this.saveAs,
  });

  Address.fromJson(dynamic json) {
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    area = json['area'];
    hint = json['hint'];
    saveAs = json['saveAs'];
  }

  String? address;
  double? latitude;
  double? longitude;
  String? area;
  String? hint;
  String? saveAs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['address'] = address;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['area'] = area;
    map['hint'] = hint;
    map['saveAs'] = saveAs;
    return map;
  }
}

// class OrderData {
//   OrderData({
//     this.orderId,
//     this.orderDetails,
//   });

//   OrderData.fromJson(dynamic json) {
//     orderId = json['orderId'];
//     orderDetails = json['orderDetails'];
//   }

//   String? orderId;
//   String? orderDetails;

//   OrderData copyWith({
//     String? orderId,
//     String? orderDetails,
//   }) =>
//       OrderData(
//         orderId: orderId ?? this.orderId,
//         orderDetails: orderDetails ?? this.orderDetails,
//       );

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['orderId'] = orderId;
//     map['orderDetails'] = orderDetails;
//     return map;
//   }
// }

class Restaurant {
  String? nukkadName;
  String? nukkadAddress;
  double? latitude;
  double? longitude;
  String? phoneNumber;

  Restaurant(
      {this.nukkadName,
      this.nukkadAddress,
      this.latitude,
      this.longitude,
      this.phoneNumber});

  Restaurant.fromJson(Map<String, dynamic> json) {
    nukkadName = json['nukkadName'];
    nukkadAddress = json['nukkadAddress'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nukkadName'] = nukkadName;
    data['nukkadAddress'] = nukkadAddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['phoneNumber'] = phoneNumber;
    return data;
  }
}

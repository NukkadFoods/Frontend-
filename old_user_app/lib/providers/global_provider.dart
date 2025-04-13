import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/order/orders_model.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'dart:developer';

class GlobalProvider extends ChangeNotifier {
  GlobalProvider() {
    getConstants();
  }
  Map<String, List<CartModel>> carts = {};
  FetchAllRestaurantsModel? restaurants;
  List<Orders> ongoingOrders = [];
  bool showCarts = false;
  late GlobalKey cardKey;
  double? height;
  double freeDeliveryOver = 0;
  late Map<String, dynamic> constants;
  UserModel? user;
  int streak = 0;
  bool orderedToday = false;
  bool firstOrder = false;

  getConstants() async {
    constants = (await FirebaseFirestore.instance
                .collection('constants')
                .doc('userApp')
                .get())
            .data() ??
        {};
    freeDeliveryOver = constants['freeDeliveryOver'].toDouble();
  }

  void updateResNames(FetchAllRestaurantsModel data) {
    restaurants = data;
    notifyListeners();
  }

  void updateCarts(List<CartModel> cart) async {
    carts.clear();
    for (int i = 0; i < cart.length; i++) {
      if (carts.containsKey(cart[i].restaurantId)) {
        carts[cart[i].restaurantId]!.add(cart[i]);
      } else {
        carts[cart[i].restaurantId] = [cart[i]];
      }
    }
    notifyListeners();
  }

  void toggleShowCarts(bool value) {
    showCarts = value;
    if (value) {
      height = cardKey.currentContext!.size!.height;
    } else {
      height = null;
    }
    // notifyListeners();
  }

  void removeCart(String restaurantId, BuildContext context) async {
    if (carts.length == 1) {
      carts.clear();
      UserController.updateUserById(
          id: SharedPrefsUtil().getString(AppStrings.userId)!,
          updateData: {'cart': []},
          context: context);
    }
    carts.remove(restaurantId);
    notifyListeners();
    List<Map> newCart = [];
    carts.values.forEach((cart) {
      cart.forEach((item) {
        newCart.add(item.toJson());
      });
    });
    UserController.updateUserById(
        id: SharedPrefsUtil().getString(AppStrings.userId)!,
        updateData: {'cart': newCart},
        context: context);
  }

  void addOngoingOrder(List<Orders> order) {
    ongoingOrders = order;
    log(ongoingOrders.length.toString());
    notifyListeners();
  }

  void updateStreak(int s) {
    streak = s;
    notifyListeners();
  }

  void clear() {
    carts.clear();
    restaurants = null;
    ongoingOrders.clear();
  }
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/orders/order_controller.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OrderFoundProvider extends ChangeNotifier {
  OrderFoundProvider({required this.orderData}) {
    getRestaurantDetails();
    getUserPosition();
  }
  LatLng? userPosition;
  OrderData orderData;
  Restaurant? restaurantDetails;
  bool restaurantFetched = false;
  // String baseurl = dotenv.env['BASE_URL']!;
  String baseurl = AppStrings.baseURL;
  Map? billingData = {};
  double dropDistance = 0;
  double pickDistance = 0;

  void getRestaurantDetails() async {
    final response = await http.post(Uri.parse(
        '$baseurl/auth/getRestaurantUser/${orderData.restaurantuid}'));
    print(jsonDecode(response.body)['user']['restaurantImages']);
    if (response.statusCode == 200) {
      restaurantDetails =
          Restaurant.fromJson(jsonDecode(response.body)['user']);
      if (userPosition == null) {
        await getUserPosition();
      }
      restaurantFetched = true;
      billingData = orderData.billingDetail;
      getOtherData();
      try {
        notifyListeners();
      } catch (e) {}
    } else {
      print(response.statusCode);
    }
  }

  void getOtherData() {
    dropDistance = (Geolocator.distanceBetween(
            restaurantDetails!.latitude!,
            restaurantDetails!.longitude!,
            userPosition!.latitude,
            userPosition!.longitude) /
        1000);
    pickDistance = (Geolocator.distanceBetween(
            restaurantDetails!.latitude!,
            restaurantDetails!.longitude!,
            DutyController.position.latitude,
            DutyController.position.longitude) /
        1000);
  }

  Future<void> getUserPosition() async {
    var data = await FirebaseFirestore.instance
        .collection('tracking')
        .doc(orderData.orderId!)
        .get();
    userPosition = LatLng(data.data()!['userLat'], data.data()!['userLng']);
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/notification.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:http/http.dart' as http;

import '../controller/toast.dart';

class LiveTaskProvider extends ChangeNotifier {
  LiveTaskProvider(this.orderData, this.userLocation) {
    getUserPhonenumber(orderData.orderByid!);
    initTimer();
  }
  //Declaration
  bool pickedUp = false;
  bool showUploadImage = false;
  String userPhonenumber = '';
  final db = FirebaseFirestore.instance;
  final OrderData orderData;
  late StreamSubscription stream;
  bool? acceptedByRestaurant;
  CountDown? remainingTime;
  String? deliveryInstruction;
  int unreadByDriver = 0;
  bool isLoading = true;
  LatLng userLocation;

  //functions
  void getUserPhonenumber(String uid) async {
    // final String baseurl = dotenv.env['BASE_URL']!;
    final String baseurl = AppStrings.baseURL;
    try {
      final response =
          await http.post(Uri.parse('$baseurl/auth/getUserByID/$uid'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        userPhonenumber = responseData['user']['contact'];
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: "No Internet", isError: true);
      }
    }
    final data =
        (await db.collection('tracking').doc(orderData.orderId).get()).data() ??
            {};
    deliveryInstruction = data['deliveryInstruction'];
    final pickedup = data['pickedup'];
    isLoading = false;
    if (pickedup == true) {
      acceptedByRestaurant = true;
      setPickedUp(true);
    }
    stream = db
        .collection('tracking')
        .doc(orderData.orderId)
        .snapshots()
        .listen((snapshot) {
      if (acceptedByRestaurant != true) {
        acceptedByRestaurant = snapshot.get('acceptedByRestaurant');
      }
      pickedUp = snapshot.data()!['pickedup'] ?? false;
      unreadByDriver = snapshot.data()!['unreadByDriver'] ?? 0;
      notifyListeners();
    });
  }

  void togglePickedUp() {
    pickedUp = !pickedUp;
    notifyListeners();
  }

  void toggleReachedPickedUp() {
    showUploadImage = !showUploadImage;
    notifyListeners();
  }

  void setPickedUp(bool value) {
    pickedUp = value;
    notifyListeners();
  }

  void initTimer() async {
    final now = DateTime.now();
    final expectedBy = DateTime.parse(orderData.timetoprepare!);
    remainingTime = CountDown(
        expectedBy.difference(now).inSeconds,
        expectedBy
            .difference(DateTime.parse(
                orderData.date!.substring(0, orderData.date!.length - 1)))
            .inSeconds);
    notifyListeners();
  }

  void sendReachedNotification() async {
    final position = await Geolocator.getCurrentPosition();
    if (Geolocator.distanceBetween(position.latitude, position.longitude,
            userLocation.latitude, userLocation.longitude) <
        200) {
      NotificationService.sendNotification(
        toUid: orderData.orderByid!,
        toApp: "user",
        title: "Your order is almost there!",
        body:
            "Our delivery partner is nearby and will deliver your order shortly.",
      );
    }
  }
}

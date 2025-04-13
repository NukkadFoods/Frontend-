import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../controller/toast.dart';

class LiveTaskProvider extends ChangeNotifier {
  LiveTaskProvider(this.orderData) {
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
      unreadByDriver = snapshot.data()!['unreadByDriver'] ?? 0;
      stream.cancel();
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
}

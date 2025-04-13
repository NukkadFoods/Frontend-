import 'dart:async' show StreamSubscription;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/material.dart';

class PickupProvider extends ChangeNotifier {
  PickupProvider(this.orderId) {
    getOtp();
  }
  // final String baseurl = dotenv.env['BASE_URL']!;
  final String baseurl = AppStrings.baseURL;
  String otp = "";
  bool showButton = false;
  String orderId;
  bool pickedUp = false;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> stream;

  void getOtp() async {
    otp = (await FirebaseFirestore.instance
            .collection('tracking')
            .doc(orderId)
            .get())
        .data()!['pickupOtp']
        .toString();
    stream = FirebaseFirestore.instance
        .collection('tracking')
        .doc(orderId)
        .snapshots()
        .listen((data) {
      if (data.data()!['pickedup'] == true) {
        pickedUp = true;
        notifyListeners();
        stream.cancel();
      }
    });
    notifyListeners();
  }

  void toggleShowButton() {
    showButton = !showButton;
    notifyListeners();
  }
}

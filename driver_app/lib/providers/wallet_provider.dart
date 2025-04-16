import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/wallet_controller.dart';
import 'package:driver_app/widgets/constants/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:math';
// import 'dart:developer' as dev;

class WalletProvider extends ChangeNotifier {
  WalletProvider() {
    syncWallet();
  }
  // void createWallet() {
  //   WalletController.createWallet();
  // }
  String referralCode = '';
  double balance = 0.0;
  void syncWallet() async {
    if (!WalletController.loaded) {
      await WalletController.getWallet();
    }
    if (WalletController.wallet != null) {
      balance = WalletController.wallet!.amount!;
    }
    final temp = SharedPrefsUtil().getString('referralCode');
    print(temp);
    if (temp == null) {
      final referralMap = (await FirebaseFirestore.instance
              .collection('constants')
              .doc('referralCodes')
              .get())
          .data()!;
      referralCode = referralMap.entries.firstWhere(
        (element) {
          return element.value == WalletController.uid;
        },
        orElse: () => const MapEntry('error', 'error'),
      ).key;
      if (referralCode == 'error') {
        await completeReferral(WalletController.uid);
      }
      SharedPrefsUtil().setString('referralCode', referralCode);
    } else {
      referralCode = temp;
    }
    notifyListeners();
  }

  Future<void> completeReferral(String uid) async {
    final dbRef =
        FirebaseFirestore.instance.collection('constants').doc('referralCodes');
    final referralCodes = (await dbRef.get()).data()!;
    String generatedCode = '';
    do {
      generatedCode = getRandomString(7);
    } while (referralCodes.containsKey(generatedCode));
    dbRef.update({generatedCode: uid});
    referralCode = generatedCode;
  }

  String getRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
/*
  void test() async {
    FirebaseFirestore.instance.collection('dboys').doc('8828767828').update({
      "orders.2803256733742-69299": {
        "accepted": true,
        "orderId": "2803256733742-69299",
        "Restaurantuid": "67d001580d2f2917e8ff2bf4",
        "cookingDescription": "No request",
        "drivertip": 0,
        "couponcode": "no code",
        "date": "2025-03-28T12:55:21.406Z",
        "time": "12:55 PM",
        "paymentMethod": "Paid online",
        "totalCost": 217.07,
        "gst": 7.7,
        "itemAmount": 170,
        "deliveryCharge": 14.91,
        "convinenceFee": 12.67,
        "orderByid": "67e64892023949df359da8c8",
        "orderByName": "Gaurav",
        "status": "Pending",
        "deliveryAddress": "hdkbdd, bdha, bdha ,bdha",
        "items": [
          {
            "itemId": "67d0015Schezwan Noodles",
            "itemName": "Schezwan Noodles",
            "itemQuantity": 1,
            "unitCost": 170,
            "_id": "67e64eee924b660d336ac80f"
          }
        ],
        "timetoprepare": "2025-03-28 13:09:27.328652",
        "ordertype": "Delivery",
        "billingDetail": {
          "surge": 0,
          "delivery_boy_wallet_cash": 4.41,
          "shortValueOrder": 11.79,
          "gst": 7.7,
          "total_delivery_boy_earning": 35.67,
          "dov": 10,
          "dDist": 4.91,
          "nukkad_earning": 131.22,
          "usable_wallet_cash": 15.93,
          "customer_wallet_cash_earned": 0,
          "nukkad_wallet_cash": 10.86,
          "delivery_fee": 14.91,
          "total": 217.07,
          "nukkadfoods_comission": 38.78,
          "expectedPrep": "2025-03-28T13:09:27.323239",
          "handling_charges": 6.72,
          "delivery_boy_earning": 31.26,
          "longDistanceCharge": 0,
          "packing_charges": 5.95,
          "order_value": 170,
          "lateDelivery": true
        },
      }
    });
  }*/

  //   try {
  //     final allocate = FirebaseFunctions.instance.httpsCallable("allocate");
  //     final map = {
  //       "orderId": "2803256733742-69299",
  //       "Restaurantuid": "67d001580d2f2917e8ff2bf4",
  //       "cookingDescription": "No request",
  //       "drivertip": 0,
  //       "couponcode": "no code",
  //       "date": "2025-03-28T12:55:21.406Z",
  //       "time": "12:55 PM",
  //       "paymentMethod": "Paid online",
  //       "totalCost": 217.07,
  //       "gst": 7.7,
  //       "itemAmount": 170,
  //       "deliveryCharge": 14.91,
  //       "convinenceFee": 12.67,
  //       "orderByid": "67e64892023949df359da8c8",
  //       "orderByName": "Gaurav",
  //       "status": "Pending",
  //       "deliveryAddress": "hdkbdd, bdha, bdha ,bdha",
  //       "items": [
  //         {
  //           "itemId": "67d0015Schezwan Noodles",
  //           "itemName": "Schezwan Noodles",
  //           "itemQuantity": 1,
  //           "unitCost": 170,
  //           "_id": "67e64eee924b660d336ac80f"
  //         }
  //       ],
  //       "timetoprepare": "2025-03-28 13:09:27.328652",
  //       "ordertype": "Delivery",
  //       "billingDetail": {
  //         "surge": 0,
  //         "delivery_boy_wallet_cash": 4.41,
  //         "shortValueOrder": 11.79,
  //         "gst": 7.7,
  //         "total_delivery_boy_earning": 35.67,
  //         "dov": 10,
  //         "dDist": 4.91,
  //         "nukkad_earning": 131.22,
  //         "usable_wallet_cash": 15.93,
  //         "customer_wallet_cash_earned": 0,
  //         "nukkad_wallet_cash": 10.86,
  //         "delivery_fee": 14.91,
  //         "total": 217.07,
  //         "nukkadfoods_comission": 38.78,
  //         "expectedPrep": "2025-03-28T13:09:27.323239",
  //         "handling_charges": 6.72,
  //         "delivery_boy_earning": 31.26,
  //         "longDistanceCharge": 0,
  //         "packing_charges": 5.95,
  //         "order_value": 170,
  //         "lateDelivery": true
  //       },
  //     };
  //     map['accepted'] = false;
  //     allocate.call({
  //       'order': map,
  //       "restaurant": {'lat': 29.777, 'lng': 78.0999},
  //       'hubId': "fet",
  //       'user': {'lat': 29.777, 'lng': 78.0999}
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}

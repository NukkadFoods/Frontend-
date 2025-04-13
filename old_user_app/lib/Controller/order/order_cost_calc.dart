// import 'dart:convert';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class OrderCostCalculator {
  static Future<Map?> getCost(OrderCostRequestModel request) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable("calculate");
    try {
      final response = await callable.call(request.toJson());
      return response.data;
    } catch (e) {
      Toast.showToast(message: "Unable to get billing details", isError: true);
      log("error: ${e.toString()}");
      return null;
    }
  }
}

// class OrderCostModel {
//   double? orderValue;
//   double? deliveryCharge;
//   double? handlingCharges;
//   double? packingCharges;
//   double? walletCoinsEarned;
//   double? deliveryGuyCoins;
//   double? nukkadCommission;

//   OrderCostModel(
//       {this.orderValue,
//       this.deliveryCharge,
//       this.handlingCharges,
//       this.packingCharges,
//       this.walletCoinsEarned,
//       this.deliveryGuyCoins,
//       this.nukkadCommission});

//   OrderCostModel.fromJson(Map<String, dynamic> json) {
//     orderValue = double.tryParse(json['orderValue'].toString());
//     deliveryCharge = json['deliveryCharge'] == null
//         ? 0.0
//         : double.tryParse(json['deliveryCharge'].toString());
//     handlingCharges = double.tryParse(json['handlingCharges'].toString());
//     packingCharges = double.tryParse(json['packingCharges'].toString());
//     walletCoinsEarned = double.tryParse(json['walletCoinsEarned'].toString());
//     deliveryGuyCoins = json['deliveryGuyCoins'] == null
//         ? 0.0
//         : double.tryParse(json['deliveryGuyCoins'].toString());
//     nukkadCommission = double.tryParse(json['nukkadCommission'].toString());
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['orderValue'] = orderValue;
//     data['deliveryCharge'] = deliveryCharge;
//     data['handlingCharges'] = handlingCharges;
//     data['packingCharges'] = packingCharges;
//     data['walletCoinsEarned'] = walletCoinsEarned;
//     data['deliveryGuyCoins'] = deliveryGuyCoins;
//     data['nukkadCommission'] = nukkadCommission;
//     return data;
//   }

//   double total() {
//     print('deliveryCharge=$deliveryCharge');
//     if (orderValue != null &&
//         deliveryCharge != null &&
//         handlingCharges != null &&
//         packingCharges != null) {
//       return orderValue! + deliveryCharge! + handlingCharges! + packingCharges!;
//     } else {
//       return 0.0;
//     }
//   }
// }

enum DeliveryAndPreparationStatus { ontime, late }


class OrderCostRequestModel {
  double? orderValue;
  double? distanceInKms;
  String? preparationStatus;
  String? deliveryStatus;
  String? isPremium;
  String? isSurge;
  String? surgeType;

  OrderCostRequestModel(
      {required this.orderValue,
      required this.distanceInKms,
      required DeliveryAndPreparationStatus preparationStatus,
      required DeliveryAndPreparationStatus deliveryStatus,
      required this.isPremium,
      required this.isSurge,
    required this.surgeType}) {
    if (preparationStatus == DeliveryAndPreparationStatus.late) {
      this.preparationStatus = 'late';
    } else if (preparationStatus == DeliveryAndPreparationStatus.ontime) {
      this.preparationStatus = 'ontime';
    }
    if (deliveryStatus == DeliveryAndPreparationStatus.late) {
      this.deliveryStatus = 'late';
    } else if (deliveryStatus == DeliveryAndPreparationStatus.ontime) {
      this.deliveryStatus = 'ontime';
    }
    if (isSurge == 'yes' && surgeType == null) {
      throw Exception('Surge Type Cant be null if isSurge is Yes');
    }
    // if (isSurge == 'yes' && surgeType != null) {
    //   switch (surgeType) {
    //     case Surge.cold:
    //       this.surgeType = 'cold';
    //       break;
    //     case Surge.heatwave:
    //       this.surgeType = 'heatwave';
    //       break;
    //     case Surge.postmidnight:
    //       this.surgeType = 'postmidnight';
    //       break;
    //     case Surge.rain:
    //       this.surgeType = 'rain';
    //       break;
    //     case Surge.traffic:
    //       this.surgeType = 'traffic';
    //       break;
    //   }
    // }
    // if (isSurge == 'no' && surgeType == null) {
    //   this.surgeType = 'cold';
    // }
  }

  OrderCostRequestModel.fromJson(Map<String, dynamic> json) {
    orderValue = json['orderValue'];
    distanceInKms = json['distanceInKms'];
    preparationStatus = json['preparationStatus'];
    deliveryStatus = json['deliveryStatus'];
    isPremium = json['isPremium'];
    isSurge = json['isSurge'];
    surgeType = json['surgeType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_value'] = orderValue;
    data['distance'] = distanceInKms;
    data['preparation'] = preparationStatus;
    data['delivery'] = deliveryStatus;
    data['premium'] = isPremium;
    data['surge'] = isSurge;
    data['surge_type'] = surgeType;
    print(data);
    return data;
  }
}
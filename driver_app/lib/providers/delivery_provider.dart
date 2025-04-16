import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/earnings/earnings_controller.dart';
import 'package:driver_app/controller/notification.dart';
import 'package:driver_app/controller/orders/order_controller.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/controller/wallet_controller.dart';
import 'package:driver_app/screens/live_task_screens/delivery_completed_screen.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/constants/shared_preferences.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeliveryProvider extends ChangeNotifier {
  // final String baseurl = dotenv.env['BASE_URL']!;
  final String baseurl = AppStrings.baseURL;
  DeliveryProvider(this.orderData, this.restaurant) {
    controller1.addListener(notifyListeners);
    controller2.addListener(notifyListeners);
    controller3.addListener(notifyListeners);
    controller4.addListener(notifyListeners);
  }
  OrderData orderData;
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  bool otpSent = false;
  bool sendingOtp = false;
  bool verifyingOtp = false;
  String otp = '';
  Restaurant restaurant;

  bool showButton() {
    return (controller1.text != '' &&
        controller2.text != '' &&
        controller3.text != '' &&
        controller4.text != '');
  }

  void verifyOtp(
      BuildContext context, OrderData orderData, Map billingData) async {
    if (!(controller1.text +
            controller2.text +
            controller3.text +
            controller4.text ==
        otp)) {
      Toast.showToast(message: "Incorrect OTP", isError: true);
    } else {
      verifyingOtp = true;
      notifyListeners();
      billingData['lateDelivery'] =
          DateTime.now().isAfter(DateTime.parse(orderData.timetoprepare!));
      orderData.billingDetail!['lateDelivery'] = billingData['lateDelivery'];
      try {
        final response = await http.put(
            Uri.parse(
                '$baseurl/order/orders/${orderData.orderByid!}/${orderData.orderId!}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "updateData": {
                "status": "Delivered",
                // "billingDetail": billingData
              }
            }));

        if (response.statusCode == 200) {
          orderData = OrderData.fromJson(jsonDecode(response.body)['order']);
          orderData.billingDetail!['lateDelivery'] =
              billingData['lateDelivery'];
          http.put(
              Uri.parse(
                  '$baseurl/order/orders/${orderData.orderByid!}/${orderData.orderId!}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "updateData": {"billingDetail": orderData.billingDetail!}
              }));
          if (!(await OrderController.orderDelivered(orderData))) {
            verifyingOtp = false;
            notifyListeners();
            Toast.showToast(
                message: "Unable to complete order. Retry!", isError: true);
            return;
          }

          compute(completePayments, <String, dynamic>{
            'orderData': orderData,
            'driverUid': SharedPrefsUtil().getString('uid')!,
            'restaurant': restaurant,
            "baseUrl": baseurl,
            'driverName': WalletController.wallet!.username
          });
          FirebaseFirestore.instance.runTransaction((transaction) async {
            if (orderData.billingDetail!['foodieReward'] != null &&
                orderData.billingDetail!['foodieReward'] != 0) {
              transaction.update(
                  FirebaseFirestore.instance
                      .collection('constants')
                      .doc('streakRecord'),
                  {orderData.orderByid!: orderData.date!.substring(0, 10)});
              //Sending notification to user for foodie reward
              NotificationService.sendNotification(
                toUid: orderData.orderByid!,
                toApp: 'user',
                title: "Yay! Foodie Reward Received",
                body:
                    "Foodie Reward of ₹ ${orderData.billingDetail!['foodieReward']} has been credited to wallet!",
                data: {
                  "orderId": orderData.orderId,
                },
              );
            }
            transaction.update(
                FirebaseFirestore.instance
                    .collection("tracking")
                    .doc(orderData.orderId!),
                {"status": "Delivered"});
          });
          await sendNotifications(orderData);
          Navigator.of(context).pushReplacement(transitionToNextScreen(
              DeliveryCompletedScreen(
                  amount: billingData['lateDelivery'] == true
                      ? billingData['delivery_boy_earning'].toString()
                      : billingData['total_delivery_boy_earning'].toString())));
        } else {
          Toast.showToast(
              message: 'Unable to update status.  Retry!!!', isError: true);
        }
      } catch (e) {
        print('error occured');
        print(e);
      }
      verifyingOtp = false;
      notifyListeners();
    }
  }

  void sendOtp() async {
    sendingOtp = true;
    notifyListeners();
    final ref = await FirebaseFirestore.instance
        .collection('tracking')
        .doc(orderData.orderId!)
        .get();
    otp = ref.get('otp');
    if (otp.isNotEmpty) {
      otpSent = true;
    }
    sendingOtp = false;
    notifyListeners();
  }

  ///Give {'orderData':OrderData , 'driverUid': String , 'restaurant': Restaurant, 'baseUrl':String, "driverName":String} as arguments
  static void completePayments(Map data) async {
    OrderData orderData = data['orderData'];
    String driverUid = data['driverUid'];
    Restaurant restaurant = data['restaurant'];
    String baseUrl = data['baseUrl'];
    EarningsController.endpoint = "$baseUrl/earnings";
    WalletController.baseurl = baseUrl;
    WalletController.wallet = Wallet(username: data['driverName']);

    bool rEarningCreated = false,
        dEarningCreated = false,
        dWalletCredited = false,
        rWalletCredited = false,
        userWalletCredited =
            orderData.billingDetail!['customer_wallet_cash_earned'] == null ||
                orderData.billingDetail!['customer_wallet_cash_earned'] == 0,
        foodieRewardCredited = orderData.billingDetail!['foodieReward'] == null,
        userRewardForLate =
            !(orderData.billingDetail!['lateDelivery'] == true ||
                orderData.billingDetail!['latePrep'] == true),
        riderTipCredited = orderData.drivertip == 0;

    double rewardToUser = 0;

    while (!(rEarningCreated &&
        dEarningCreated &&
        dWalletCredited &&
        rWalletCredited &&
        userWalletCredited &&
        foodieRewardCredited &&
        riderTipCredited &&
        userRewardForLate)) {
      if (!dEarningCreated) {
        dEarningCreated = await EarningsController.addEarning(
            uid: driverUid,
            orderId: orderData.orderId!,
            userId: orderData.orderByid!,
            amount:
                orderData.billingDetail!['delivery_boy_earning'].toDouble());
      }

      if (!riderTipCredited) {
        riderTipCredited = await EarningsController.addEarning(
            uid: driverUid,
            orderId: "tip_${orderData.orderId!}",
            userId: orderData.orderByid!,
            amount: orderData.drivertip ?? 0);
      }

      if (!rEarningCreated) {
        rEarningCreated = await EarningsController.addEarning(
            uid: orderData.restaurantuid!,
            orderId: orderData.orderId!,
            userId: orderData.orderByid!,
            amount: (orderData.billingDetail!["nukkad_earning"] -
                    (orderData.billingDetail!["discount"] ?? 0))
                .toDouble());
      }

      if (!foodieRewardCredited) {
        if (orderData.billingDetail!['foodieReward'] != null &&
            orderData.billingDetail!['foodieReward'] != 0) {
          foodieRewardCredited = await WalletController.creditToUser(
              orderData.orderByid!,
              orderData.billingDetail!['foodieReward'].toDouble(),
              "Foodie Reward",
              orderData.orderByName ?? "");
        } else {
          foodieRewardCredited = true;
        }
      }

      if (!userWalletCredited) {
        if (orderData.billingDetail!['customer_wallet_cash_earned'] != 0) {
          userWalletCredited = await WalletController.creditToUser(
              orderData.orderByid!,
              orderData.billingDetail!['customer_wallet_cash_earned']
                  .toDouble(),
              "Reward for orderId: ${orderData.orderId}",
              orderData.orderByName ?? "");
        } else {
          userWalletCredited = true;
        }
      }

      if (!dWalletCredited) {
        if (orderData.billingDetail!['lateDelivery'] == true) {
          rewardToUser +=
              orderData.billingDetail!['delivery_boy_wallet_cash'].toDouble();
          dWalletCredited = true;
        } else {
          WalletController.uid = driverUid;
          dWalletCredited = await WalletController.credit(
              orderData.billingDetail!['total_delivery_boy_earning']
                      .toDouble() -
                  orderData.billingDetail!['delivery_boy_earning'].toDouble(),
              "For orderId: ${orderData.orderId}");
        }
      }

      if (!rWalletCredited) {
        if (orderData.billingDetail!['latePrep'] == true) {
          rewardToUser +=
              orderData.billingDetail!['nukkad_wallet_cash'].toDouble();
          rWalletCredited = true;
        } else {
          rWalletCredited = await WalletController.creditToRestaurant(
              orderData.restaurantuid!,
              orderData.billingDetail!['nukkad_wallet_cash'].toDouble(),
              "For orderId: ${orderData.orderId}",
              restaurant.nukkadName ?? "");
        }

        if (!userRewardForLate) {
          userRewardForLate = await WalletController.creditToUser(
              orderData.orderByid!,
              rewardToUser,
              "Reward for orderId: ${orderData.orderId}",
              orderData.orderByName ?? "");
        }
      }
    }
    print("compute completed");
  }

  Future<void> sendNotifications(OrderData orderData) async {
    NotificationService.sendNotification(
        toUid: orderData.restaurantuid!, toApp: "restaurant");
    NotificationService.sendNotification(
        toUid: orderData.orderByid!,
        toApp: "user",
        title: "Order Delivered",
        body: "Your order from ${restaurant.nukkadName ?? ""} has delivered.",
        data: {"orderId": orderData.orderId});
  }
}

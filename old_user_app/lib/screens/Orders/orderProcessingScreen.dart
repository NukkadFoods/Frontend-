import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/order/order_controller.dart';
import 'package:user_app/Controller/order/order_model.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Orders/orderanimation.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class OrderProcessingScreen extends StatefulWidget {
  final OrderModel orderModel;
  final UserModel user;
  final String? deliveryInstruction;
  final String? txnId;

  const OrderProcessingScreen(
      {super.key,
      required this.orderModel,
      required this.user,
      this.deliveryInstruction,
      this.txnId});

  @override
  OrderProcessingScreenState createState() => OrderProcessingScreenState();
}

class OrderProcessingScreenState extends State<OrderProcessingScreen> {
  bool _isOrderPlaced = false;
  bool _hasError = false;
  String _errorMessage = '';
  double? userlat;
  double? userlong;
  String otp = '';
  late Restaurants nukkad;

  @override
  void initState() {
    super.initState();
    getAddressTypeSelected();
  }

  Future<void> getAddressTypeSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userlat = prefs.getDouble('CurrentLatitude');
      userlong = prefs.getDouble('CurrentLongitude');
      print('firebase userlocation : $userlat , $userlong');
    });
    nukkad = context
        .read<GlobalProvider>()
        .restaurants!
        .restaurants!
        .firstWhere(
            (res) => res.id == widget.orderModel.orderData.Restaurantuid);
    await _processOrder();
  }

  String generateOTP() {
    Random random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  Future<void> _processOrder() async {
    otp = generateOTP();
    try {
      final result = await OrderController.createOrder(
        context: context,
        orderData: widget.orderModel,
      );

      result.fold(
        (errorMessage) {
          setState(() {
            _hasError = true;
            if (widget.txnId != null) {
              _errorMessage =
                  "Some error occured while placing order, Please note the below transaction id and contact support for refund.\nTransaction Id:\n${widget.txnId}";
            } else {
              _errorMessage = errorMessage;
            }
          });
        },
        (successMessage) async {
          _completeReferral();
          setState(() {
            _isOrderPlaced = true;
          });

          await FirebaseFirestore.instance
              .collection('tracking')
              .doc(widget.orderModel.orderData.orderId)
              .set({
            'txnId': widget.txnId ?? "No transaction id",
            'userLng': userlong,
            'userLat': userlat,
            'lat': 0.0,
            'lng': 0.0,
            'dBoyId': 'unassigned',
            'otp': otp,
            'pickupOtp': generateOTP(),
            'acceptedByRestaurant': null,
            'deliveryInstruction': widget.deliveryInstruction,
            'status': 'Pending',
            "messages": [],
            "unreadByDriver": 0,
            "unreadByUser": 0,
          });
          final functions = FirebaseFunctions.instance;
          if (widget.orderModel.orderData.ordertype == 'Delivery') {
            try {
              final allocate = functions.httpsCallable("allocate");
              final map = widget.orderModel.orderData.toJson();
              map['accepted'] = false;
              allocate.call({
                'order': map,
                "restaurant": {'lat': nukkad.latitude, 'lng': nukkad.longitude},
                'hubId': nukkad.hubId,
                'user': {'lat': userlat!, 'lng': userlong!}
              });
            } catch (e) {
              print(e);
            }
          }

          //Sending notification to restaurant
          try {
            final sendNotification =
                functions.httpsCallable('sendNotification');
            sendNotification.call({
              "uid": widget.orderModel.orderData.Restaurantuid,
              "toApp": "restaurant",
              "title": "New Order Received",
              "body":
                  "A new ${widget.orderModel.orderData.ordertype} order has been received",
              "data": {
                "orderId": widget.orderModel.orderData.ordertype,
                "status": "Pending"
              },
              "channel": "orders"
            });
          } catch (e) {
            print(e);
          }

          // Optionally update user cart
          await _updateUser();
        },
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to process order. Please try again.';
      });
    }
  }

  Future<void> _updateUser() async {
    UserController.updateUserById(
      id: SharedPrefsUtil().getString(AppStrings.userId) ?? '',
      updateData: {"cart": []},
      context: context,
    );

    if (mounted) {
      // Check if context is still valid
      Navigator.of(context).pushReplacement(
        transitionToNextScreen(
          OrderAnimation(
            orderData: widget.orderModel.orderData,
          ),
        ),
      );
    }
  }

  Future<void> _completeReferral() async {
    String? code =
        context.read<GlobalProvider>().user!.user!.referredby!['reference'];
    if (context.read<GlobalProvider>().firstOrder && code != 'none') {
      double amount =
          context.read<GlobalProvider>().constants['referral_amount'] ?? 0;
      WalletController.credit(amount, "Referral reward on first order");
      String? uidOfOtherUser = (await FirebaseFirestore.instance
              .collection('constants')
              .doc('referralCodes')
              .get())
          .get(code!);
      if (uidOfOtherUser != null) {
        String baseUrl = SharedPrefsUtil().getString('base_url')!;
        final response =
            await post(Uri.parse("$baseUrl/auth/getUserByID/$uidOfOtherUser"));
        if (response.statusCode == 200) {
          String userName = jsonDecode(response.body)['user']['userName'];
          WalletController.creditToOtherUser(
              uidOfOtherUser,
              amount,
              'Referral reward on first order placed by ${WalletController.wallet!.username}.',
              userName);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
          // Center Content
          Center(
            child: _hasError
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SvgPicture.asset(
                        //   'assets/images/error_icon.svg',
                        //   height: 20.h,
                        //   color: primaryColor,
                        // ),
                        const Icon(
                          Icons.error,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: h4TextStyle.copyWith(color: primaryColor),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _isOrderPlaced
                          ? Lottie.asset('assets/animations/gpay.json')
                          : Lottie.asset(
                              'assets/animations/order_process.json',
                              height: 20.h,
                            ),
                      SizedBox(height: 2.h),
                      Text(
                        _isOrderPlaced
                            ? 'Order Placed...'
                            : 'Processing Order...',
                        style: h3TextStyle.copyWith(color: primaryColor),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

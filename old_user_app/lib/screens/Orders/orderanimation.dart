import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/screens/Orders/OrderTrackingScreen.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:vibration/vibration.dart';

import '../../Controller/order/order_model.dart';
import '../../widgets/constants/strings.dart';

class OrderAnimation extends StatefulWidget {
  final OrderData orderData;

  const OrderAnimation({super.key, required this.orderData});
  @override
  _OrderAnimationState createState() => _OrderAnimationState();
}

class _OrderAnimationState extends State<OrderAnimation> {
  late Restaurants? nukkad;
  @override
  void initState() {
    super.initState();
    // Trigger vibration when the screen is initialized
    _triggerVibration();
  }

  Future<void> getres() async {
    final response = await http.post(
      Uri.parse(
          '${AppStrings.baseURL}/auth/getRestaurantUser/${widget.orderData.Restaurantuid}'),
    );

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['executed']) {
        var user = res['user'];
        nukkad = Restaurants.fromJson(user);

        var time = nukkad!.distanceFromUser;
        print('distance from user $time');
      } else {
        print('Restaurant not found.');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void _triggerVibration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('estimatedtime');
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 1000);
     
    } await getres();
      Future.delayed(const Duration(seconds: 4), () async {
        Navigator.of(context).pushReplacement(
          transitionToNextScreen(OrderTrackingScreen(
            isDelivery: widget.orderData.ordertype == "Delivery",
            nukkad: nukkad!,
            Amount: widget.orderData.totalCost.toString(),
            orderid: widget.orderData.orderId,
            // Status: 'Pending',
            time: widget.orderData.time,
            deliveryTime: DateTime.tryParse(widget.orderData.timetoprepare)!,
            orderedAt: DateTime.tryParse(widget.orderData.date)!,
          )),
        );
      }); // Vibrate for 500ms
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: Image.asset('assets/images/background.png'),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 0, right: 5, left: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Yum !', style: h3TextStyle.copyWith(color: primaryColor)),
                SizedBox(height: 1.h),
                Text(
                  'Your order is in the works',
                  style: h3TextStyle.copyWith(color: primaryColor),
                ),
                SizedBox(height: 3.h),
                Text(
                  'We’ll keep you updated every step of the way so you know exactly when to expect your meal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isdarkmode ? textGrey2 : textGrey1),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 7.h),
                    Lottie.asset('assets/animations/scooter.json'),
                    Image.asset('assets/images/grass.png'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

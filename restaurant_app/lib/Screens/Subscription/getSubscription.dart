import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/subscription/subscription_resquest.dart';
import 'package:restaurant_app/Screens/Payments/payments_screen.dart';
import 'package:restaurant_app/Screens/Subscription/subscribe_card.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';

import 'package:sizer/sizer.dart';

class GetSubscription extends StatefulWidget {
  const GetSubscription({super.key});

  @override
  State<GetSubscription> createState() => _GetSubscriptionState();
}

class _GetSubscriptionState extends State<GetSubscription> {
  var userid;
  @override
  void initState() {
    super.initState();
    userid = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    SubscribeController.getSubscriptionById(context: context, id: userid);
  }

  Widget _buildRow(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: Colors.black,
        ),
        SizedBox(width: 2.h),
        Text(
          text,
          style: body4TextStyle.copyWith(
              color: Colors.black, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SubscribeCard(),
              Padding(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.w,
                      // height: 22.h,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.2.h, color: primaryColor),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Image.asset('assets/images/subscribe.png'),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Subscribe to Nukkad foods',
                            style: body3TextStyle.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),
                          Container(
                            width: 60.w,
                            child: Column(
                              children: [
                                // _buildRow('2x New customers'),
                                // SizedBox(height: 2.h),
                                // _buildRow('3x Repeat customers'),
                                // SizedBox(height: 2.h),
                                _buildRow('More Orders'),
                                SizedBox(height: 2.h),
                                _buildRow('More Earnings'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: mainButton(
                          'Subscribe at just ₹ 399', textWhite, routeHome),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 1.h, bottom: 2.h),
                        child: Text(
                          'For 4 Month',
                          style: body4TextStyle.copyWith(
                              color: primaryColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  routeHome() {
    // final subscribeRequest = SubscribeRequestModel(
    //     subscribeById: userid,
    //     role: 'Restaurant',
    //     subscriptionPlanId: '399 - 4 Month',
    //     startDate: time);
    // SubscribeController.subscribeUser(
    //     context: context, subscribeRequest: subscribeRequest);
    Navigator.of(context).push(transitionToNextScreen(CheckoutScreen(
      amount: 399,
      itemToBePurchased: "Subscription",
      onPaymentSuccess: () async {
        String time = DateTime.now().toIso8601String();
        final subscribeRequest = SubscribeRequestModel(
            subscribeById: SharedPrefsUtil().getString(AppStrings.userId)!,
            role: 'Restaurant',
            subscriptionPlanId: '399 - 4 Month',
            startDate: time);
        return await SubscribeController.subscribeUser(
            context: context, subscribeRequest: subscribeRequest);
      },
    )));
  }

  String getCurrentTimeInISOFormat() {
    final DateTime now = DateTime.now();
    return now.toIso8601String().split('.')[0]; // Remove milliseconds
  }
}

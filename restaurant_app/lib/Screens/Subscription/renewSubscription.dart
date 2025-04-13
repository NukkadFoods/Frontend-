import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:restaurant_app/Screens/Subscription/subscribe_card.dart';
import 'package:restaurant_app/Screens/Subscription/subscription%20_active.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/homeScreen.dart';
import 'package:sizer/sizer.dart';

class RenewSubscription extends StatefulWidget {
  const RenewSubscription({super.key});

  @override
  State<RenewSubscription> createState() => _RenewSubscriptionState();
}

class _RenewSubscriptionState extends State<RenewSubscription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back,color: textGrey1,)),
      ),
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
                          Container(height: 200,width: 200,
                            child: Image.asset(
                                'assets/images/subs_expired.png',
                                ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Subscription Expired',
                            style: body3TextStyle.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Subscribe to nukkad foods to start recieving orders',
                            style: body6TextStyle.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.black,
                              ),
                              SizedBox(width: 2.h),
                              Text(
                                '2x New customers',
                                style: body4TextStyle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.black,
                              ),
                              SizedBox(width: 2.h),
                              Text(
                                '3x Repeat customers',
                                style: body4TextStyle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.black,
                              ),
                              SizedBox(width: 2.h),
                              Text(
                                'More Orders',
                                style: body4TextStyle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.black,
                              ),
                              SizedBox(width: 2.h),
                              Text(
                                'More Earnings',
                                style: body4TextStyle.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: mainButton(
                          'Renew at just ₹ 399', textWhite, routeHome),
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}

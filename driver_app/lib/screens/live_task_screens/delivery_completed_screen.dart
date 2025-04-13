import 'dart:async';

import 'package:driver_app/controller/wallet_controller.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class DeliveryCompletedScreen extends StatelessWidget {
  const DeliveryCompletedScreen({super.key, required this.amount});
  final String amount;

  @override
  Widget build(BuildContext context) {
    WalletController.getWallet();
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    });
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                opacity: 0.7,
                image: AssetImage('assets/images/otpbbg.png'),
                fit: BoxFit.cover)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      SvgPicture.asset(
                        'assets/svgs/orderComplete.svg',
                        height: 180,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Thank You!\nOrder Completed',
                        style: TextStyle(
                            fontSize: veryLarge,
                            fontWeight: w600,
                            color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 382.5,
                    child: LottieBuilder.asset(
                      'assets/animations/confeti.json',
                      // frameRate: FrameRate(25),
                    ),
                  )
                ],
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Yay! You earned',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: w600,
                            color: colorBrightGreen)),
                    TextSpan(
                        text: '\n₹ $amount',
                        style: TextStyle(
                            fontSize: 55,
                            fontWeight: w600,
                            color: colorBrightGreen)),
                  ]))
            ],
          ),
        ),
      ),
    );
  }
}

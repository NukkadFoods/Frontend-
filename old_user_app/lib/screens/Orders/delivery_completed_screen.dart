import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/widgets/constants/colors.dart';

class DeliveryCompletedScreen extends StatelessWidget {
  const DeliveryCompletedScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    WalletController.getWallet();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
    });
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                opacity: 0.7,
                image: AssetImage('assets/images/background.png'),
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
                        'assets/images/orderComplete.svg',
                        height: 180,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Order Completed!',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: primaryColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 382.5,
                    child: LottieBuilder.asset(
                      'assets/animations/confeti.json',
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

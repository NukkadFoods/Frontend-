import 'dart:io';

import 'package:flutter/material.dart';
import 'package:user_app/screens/homeScreen.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key, this.fromHomeScreen});
  final bool? fromHomeScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: const DecorationImage(
                image: AssetImage('assets/images/background.png')),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // No internet icon
              Image.asset(
                'assets/images/noInternet.png',
                height: 120,
              ),
              const SizedBox(height: 70),
              // Title
              Text('No Internet Connection', style: h3TextStyle),
              const SizedBox(height: 10),
              // Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                    'Your internet connection is currently \nnot available please check or try \nagain.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textGrey1)),
              ),
              const SizedBox(height: 30),
              // Try Again button
              mainButton('Try Again', textWhite, () async {
                bool internetActive = false;
                try {
                  final result = await InternetAddress.lookup('example.com');
                  internetActive =
                      (result.isNotEmpty && result[0].rawAddress.isNotEmpty);
                } on SocketException catch (_) {
                  internetActive = false;
                }
                if (internetActive) {
                  if (fromHomeScreen != null && fromHomeScreen!) {
                    Navigator.of(context).pushReplacement(
                        transitionToNextScreen(const HomeScreen()));
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}

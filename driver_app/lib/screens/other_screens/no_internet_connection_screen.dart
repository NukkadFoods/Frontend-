import 'dart:io';

import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:flutter/material.dart';
// import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
// import 'package:restaurant_app/Widgets/constants/colors.dart';

class NoInternetConnectionScreen extends StatelessWidget {
  const NoInternetConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            opacity: 0.7,
            fit: BoxFit.cover,
            image: AssetImage(
              'assets/images/otpbbg.png',
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_internet.png',
              height: 200,
              width: 200,
            ),
            SizedBox(height: 30),
            Text(
              'No internet Connection',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your internet connection is currently not available please check or  try again.',
              style: TextStyle(color: colorGray),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            FullWidthGreenButton(
                label: 'Try Again',
                onPressed: () async {
                  bool internetActive = false;
                  try {
                    final result = await InternetAddress.lookup('example.com');
                    internetActive =
                        (result.isNotEmpty && result[0].rawAddress.isNotEmpty);
                  } on SocketException catch (_) {
                    internetActive = false;
                  }
                  if (internetActive) {
                    Navigator.of(context).pop(true);
                  }
                })
          ],
        ),
      ),
    );
  }
}

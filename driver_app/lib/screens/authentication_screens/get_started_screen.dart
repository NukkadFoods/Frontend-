import 'package:driver_app/screens/authentication_screens/benefits_screen.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utils/font-styles.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset('assets/animations/getStarted.json'),
            // Image.asset('assets/images/getstarted.png'),
            SizedBox(
              height: 30,
            ),
            Text(
              textAlign: TextAlign.center,
              'Join Us Today and get Benefits upto worth ₹ 20,000!',
              style: TextStyle(
                fontSize: large,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            FullWidthGreenButton(
                label: 'GET STARTED',
                onPressed: () {
                  Navigator.of(context)
                      .push(transitionToNextScreen(const BenefitsScreen()));
                })
          ],
        ),
      ),
    );
  }
}

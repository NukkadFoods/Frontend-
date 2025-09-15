import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/font-styles.dart';
import '../../widgets/common/transition_to_next_screen.dart';
import 'signin_screen.dart';

class ResetPasswordSuccessScreen extends StatelessWidget {
  const ResetPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                'Your Password has been reset!',
                style: TextStyle(
                  color: colorGreen,
                  fontSize: extraLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Image.asset('assets/images/reset.png'),
              SizedBox(
                height: 60,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushReplacement(transitionToNextScreen(SignInScreen()));
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Redirect to', // This is a string
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: mediumLarge,
                        fontWeight: FontWeight
                            .bold), // You can set a default style here
                    children: <TextSpan>[
                      TextSpan(
                        text: ' Login Page',
                        style: TextStyle(
                          fontSize: mediumLarge,
                          fontWeight: FontWeight.bold,
                          color: colorGreen,
                        ), // Custom style for this span
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

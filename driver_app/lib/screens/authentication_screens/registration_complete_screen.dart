import 'dart:async';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signin_screen.dart';

import '../../utils/colors.dart';
import '../../utils/font-styles.dart';

class RegistrationCompleteScreen extends StatefulWidget {
  const RegistrationCompleteScreen({super.key});

  @override
  State<RegistrationCompleteScreen> createState() =>
      _RegistrationCompleteScreenState();
}

class _RegistrationCompleteScreenState
    extends State<RegistrationCompleteScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to home screen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(transitionToNextScreen(
          SignInScreen())); // Make sure you have the route '/home' defined in your routes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorGreen,
                    border: Border.all(
                      width: 2,
                      color: colorGreen,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        fontSize: mediumSmall,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: 70,
                  color: colorGreen,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorGreen,
                    border: Border.all(
                      width: 2,
                      color: colorGreen,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        fontSize: mediumSmall,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: 70,
                  color: colorGreen,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorGreen,
                    border: Border.all(
                      width: 2,
                      color: colorGreen,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        fontSize: mediumSmall,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Personal\nInformation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: small,
                    color: colorGreen,
                  ),
                ),
                Text(
                  'Documentation',
                  style: TextStyle(
                    fontSize: small,
                    color: colorGreen,
                  ),
                ),
                Text(
                  'Work\nPreferences',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: small,
                    color: colorGreen,
                  ),
                ),
              ],
            ),
            Spacer(),
            Image.asset('assets/images/deliveryboy.png'),
            SizedBox(
              height: 30,
            ),
            Text(
              'Registration Complete!',
              style: TextStyle(
                color: colorGreen,
                fontWeight: FontWeight.bold,
                fontSize: veryLarge,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Yay! you have registered with us as a delivery partner! Buy your subscription now and Start earning.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(),
            ),
            SizedBox(
              height: 30,
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}

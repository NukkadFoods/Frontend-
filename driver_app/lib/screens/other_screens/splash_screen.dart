import 'dart:convert';

import 'package:driver_app/screens/authentication_screens/banned_screen.dart';
import 'package:driver_app/screens/other_screens/no_internet_connection_screen.dart';
import 'package:driver_app/widgets/common/bottom_nav_bar.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'new_intro_screen.dart';
import '../authentication_screens/signin_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void proceed(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      // Set 'isFirstLaunch' to false so that IntroScreen won't be shown again
      await prefs.setBool('isFirstLaunch', false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => IntroScreen(),
        ),
      );
    } else {
      String? uid = prefs.getString('loginKey');
      if (uid != null) {
        final String baseurl = AppStrings.baseURL;
        try {
          final response = await http
              .get(Uri.parse('$baseurl/auth/getDeliveryBoyById/$uid'));
          if (response.statusCode == 200) {
            final dboy = jsonDecode(response.body)['deliveryBoy'];
            prefs.setString('deliveryBoyData', jsonEncode(dboy));
            if (dboy['isBanned'] == true) {
              Navigator.of(context).pushReplacement(
                  transitionToNextScreen(const BannedScreen()));
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => BottomNavBar(),
                ),
              );
            }
          } else {
            await prefs.clear();
            await prefs.setBool('isFirstLaunch', false);
            FirebaseAuth.instance.signOut();
            Navigator.of(context)
                .pushReplacement(transitionToNextScreen(const SignInScreen()));
          }
        } catch (e) {
          if (e is http.ClientException) {
            await Navigator.of(context).push(
                transitionToNextScreen(const NoInternetConnectionScreen()));
            proceed(context);
          }
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set up the timer to navigate to the appropriate screen after 3 seconds
    Timer(Duration(seconds: 1), () => proceed(context));

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splashbg.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

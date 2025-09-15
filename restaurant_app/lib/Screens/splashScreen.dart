import 'dart:async';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Screens/User/login_screen.dart';
import 'package:restaurant_app/Screens/onBoardingScreen.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/homeScreen.dart';

import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), _checkFirstVisit);
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if the user has logged in before
    final String? userId = prefs.getString('User_id');

    if (userId != null) {
      _navigateToHome();
    } else {
      final bool isFirstVisit = prefs.getBool('isFirstVisit') ?? true;
      if (isFirstVisit) {
        prefs.setBool('isFirstVisit', false);
        _navigateToOnboarding();
      } else {
        _navigateToLogin();
      }
    }
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
     transitionToNextScreen( const OnBoardingScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      transitionToNextScreen( Login_Screen()),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
    transitionToNextScreen(HomeScreen()), // Change to  home screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 100.0.h,
        width: 100.0.w,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: 280,
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:user_app/Controller/notification.dart';
import 'package:user_app/Screens/homeScreen.dart'; // Import your home screen
import 'package:user_app/Screens/onBoardingScreen.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _testNotificationSetup(); // Add comprehensive FCM testing
  }
  
  Future<void> _testNotificationSetup() async {
    print('🧪 ========== COMPREHENSIVE FCM TESTING ==========');
    
    // Test 1: Basic notification validation
    Map<String, dynamic> validationResults = await NotificationService.validateNotificationSetup();
    print('📊 Validation Results:');
    validationResults.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        print('   $key: ${value['status']} - ${value['message']}');
        if (value['details'] != null) {
          print('      Details: ${value['details']}');
        }
      }
    });
    
    // Test 2: iOS-specific FCM flow test
    Map<String, dynamic> iosTestResults = await NotificationService.testIOSNotificationFlow();
    print('📱 iOS Test Summary: ${iosTestResults['summary']}');
    
    // Test 3: Current token check
    String? currentToken = await NotificationService.getCurrentToken();
    print('🔑 Current FCM Token Status: ${currentToken != null ? "✅ AVAILABLE" : "❌ NOT AVAILABLE"}');
    
    // Test 4: Check if user is logged in for token storage
    final uid = SharedPrefsUtil().getString(AppStrings.userId);
    print('👤 User Authentication: ${uid != null ? "✅ LOGGED IN ($uid)" : "❌ NOT LOGGED IN"}');
    
    print('🧪 ========== FCM TESTING COMPLETED ==========');
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(
        const Duration(seconds: 1)); // Simulate a delay for splash screen
    final userId = SharedPrefsUtil().getString(
        AppStrings.userId); // Retrieve the user ID from shared preferences
    final loginSkipped = SharedPrefsUtil().getBool("loginSkipped") ?? false;
    if ((userId != null && userId.isNotEmpty) || loginSkipped) {
      // User is logged in
      Navigator.of(context).pushReplacement(
        transitionToNextScreen(const HomeScreen()),
      ); // Navigate to home screen
    } else {
      // User is not logged in
      Navigator.of(context).pushReplacement(
        transitionToNextScreen(
            const OnBoardingScreen()), // Navigate to onboarding screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.cover,
            )));
  }
}

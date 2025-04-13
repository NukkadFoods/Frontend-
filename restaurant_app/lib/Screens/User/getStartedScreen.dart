import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Screens/User/referralScreen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/input_fields/textInputField.dart';
import 'package:restaurant_app/Widgets/noteWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  LocalController _getSavedData = LocalController();
  late Map<String, dynamic> userInfo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      Map<String, dynamic>? getData = await _getSavedData.getUserInfo();
      if (getData != null) {
        setState(() {
          userInfo = getData;
          nukkadNameController.text = userInfo['nukkadName'] ?? '';
        });
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  String nukkadName = '';
  final nukkadNameController = TextEditingController();

  routeReferral() async {
    if (nukkadName.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      var addData = {
        'nukkadName': nukkadName,
      };
      await saveUserInfo(addData);
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        transitionToNextScreen(
          const ReferralScreen(),
        ),
      );
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     backgroundColor: colorFailure,
      //     content: Text("Nukkad name is required")));
    }
  }

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', jsonEncode(userInfo));
    print('User Info Saved: ${prefs.getString('user_info')}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background image
          Positioned(
            child: Image.asset('assets/images/otpbg.png',
                fit: BoxFit.cover, height: 100.h, width: 100.w),
          ),
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Let’s get started!'.toUpperCase(),
                      style: body3TextStyle,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Your Nukkad',
                      style: h4TextStyle,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h, horizontal: 2.w),
                              child: Text(
                                'Choose how people will see your stall',
                                style: body4TextStyle.copyWith(
                                  color: textGrey2,
                                  fontWeight: FontWeight.w200,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 1.h, horizontal: 5.w),
                            child: Image.asset('assets/images/get_started.png'),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2.h),
                            child: textInputField(
                                ' *  Nukkad Name'.toUpperCase(),
                                nukkadNameController, (String name) {
                              setState(() {
                                nukkadName = name;
                              });
                            }),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2.h),
                            child: noteWidget(
                                'This is the name and picture that customers will see on the app.'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),
                  child: mainButton('Continue', textWhite, routeReferral,
                      isLoading: isLoading),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

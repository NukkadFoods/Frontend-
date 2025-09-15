import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:restaurant_app/Screens/User/login_screen.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/User/registrationTimeline.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/noteWidget.dart';
import 'package:restaurant_app/homeScreen.dart';
import 'package:sizer/sizer.dart';

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
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
     transitionToNextScreen(Login_Screen()),
      );
    });
  }
  //LoginScreen HomeScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
              child: const RegistrationTimeline(pageIndex: 4),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
              child: Image.asset(
                'assets/images/reg_complete.png',
                height: 30.h,
                
              ),
            ),
            Text(
              'Registration Completed',
              style: h3TextStyle.copyWith(color: colorSuccess),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
              child: Text(
                'We will now verify the details submitted by you and check authentication of your documents once verified, you can go live with your stalls on nukkad foods!',
                style: body3TextStyle,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 5.w, left: 5.w, bottom: 5.h),
              child: noteWidget(
                  'You will recieve SMS on your registered mobile number as soon as your stall gets verified. This may take upto 7 working days.'),
            )
          ],
        ),
      ),
    );
  }
}

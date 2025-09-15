import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';

class VerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/otpbg.png'))),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Account Under \n    Verification', style: h1TextStyle),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Your account is currently under verification. You will be notified once it has been verified. Please check back later.',
                    style: body3TextStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      textStyle: TextStyle(fontSize: 14.sp),
                    ),
                    child: Text('Back to Login',
                        style: TextStyle(color: textWhite)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

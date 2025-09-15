import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import '../../utils/colors.dart';
import '../../utils/font-styles.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: Alignment.center, children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              opacity: .5,
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/images/otpbbg.png',
              ),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LottieBuilder.asset(
                    'assets/animations/verification.json',
                    height: 170,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text('Account Under Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: extraLarge, fontWeight: FontWeight.bold)),
                  SizedBox(height: 3.h),
                  Text(
                    'Your account is currently under verification. You will be notified once it has been verified. Please check back later.',
                    style: TextStyle(fontSize: mediumSmall, color: colorGray),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(MediaQuery.of(context).size.width / 2, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      backgroundColor: colorBrightGreen,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      textStyle: TextStyle(fontSize: 14.sp),
                    ),
                    child: Text('Back to Login',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

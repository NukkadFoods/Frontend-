import 'package:driver_app/screens/authentication_screens/signin_screen.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../utils/colors.dart';
import '../../utils/font-styles.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

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
                  Icon(Icons.no_accounts_rounded, size: 150, color: Colors.red),
                  const SizedBox(
                    height: 15,
                  ),
                  Text('Banned by Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: extraLarge, fontWeight: FontWeight.bold)),
                  SizedBox(height: 3.h),
                  Text(
                    'Your account has been banned by Admin.\nContact Admin or your Nukkad Manager to lift your ban.',
                    style: TextStyle(fontSize: mediumSmall, color: colorGray),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          transitionToNextScreen(const SignInScreen()),
                          (_) => false);
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

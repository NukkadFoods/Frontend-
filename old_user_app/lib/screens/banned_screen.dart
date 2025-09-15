import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/screens/loginScreen.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: Alignment.center, children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              opacity: .5,
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/images/background.png',
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
                      textAlign: TextAlign.center, style: h1TextStyle),
                  SizedBox(height: 3.h),
                  Text(
                    'Your account has been banned by Admin.\nContact Admin or your Nukkad Manager to lift your ban.',
                    style: body3TextStyle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          transitionToNextScreen(const LoginScreen()),
                          (_) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(MediaQuery.of(context).size.width / 2, 50),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      backgroundColor: primaryColor,
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

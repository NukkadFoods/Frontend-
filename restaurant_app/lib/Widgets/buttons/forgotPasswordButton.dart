import 'package:flutter/material.dart';
import 'package:restaurant_app/Screens/Password/forgotPasswordScreen.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

Widget forgotPassButton(String userNumber, BuildContext context) {
  return Center(
    child: TextButton(
      onPressed: () {
        if (userNumber != '') {
          print('User number: $userNumber');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  ForgotPasswordScreen(userNumber: userNumber),
            ),
          );
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: Duration(seconds: 4),
                content: SizedBox(
                  height: 3.h,
                  child: Text(
                    'Enter Phone Number',
                    style: body4TextStyle,
                  ),
                ),
                backgroundColor: colorFailure,
              ),
            );
        }
      },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      child: Text('Forgot Password ?',
          style: body4TextStyle.copyWith(color: primaryColor)),
    ),
  );
}

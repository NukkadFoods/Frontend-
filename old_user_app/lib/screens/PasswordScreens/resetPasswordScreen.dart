import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/buttons/mainButton.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/input_fields/passwordField.dart';
import '../loginScreen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String newPassword = '';
  String confirmPassword = '';

  bool obscureText = true;

  void routeContinue() {
    {
      print('Password: $newPassword && Confirm Password: $confirmPassword');
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              content: SizedBox(
                height: 3.h,
                child: Text(
                  'Entered passwords do not match',
                  style: body4TextStyle.copyWith(color: textWhite),
                ),
              ),
              backgroundColor: colorFailure,
            ),
          );
      } else if (newPassword == '' || confirmPassword == '') {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              content: SizedBox(
                height: 3.h,
                child: Text(
                  'Please enter data',
                  style: body4TextStyle.copyWith(color: textWhite),
                ),
              ),
              backgroundColor: colorFailure,
            ),
          );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPage()),
        );
      }
      setState(() {
        newPassword = '';
        confirmPassword = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password', style: h4TextStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 19.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: PasswordField(
                labelText: 'New Password',
                onValueChanged: (value) {
                  setState(() {
                    newPassword = value;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 5.h),
              child: PasswordField(
                labelText: 'Confirm Password',
                onValueChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                  });
                },
              ),
            ),
            mainButton('Continue', textWhite, () => routeContinue()),
          ],
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Text(
                  'Your Password has been reset!',
                  style: h1TextStyle.copyWith(color: primaryColor),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Center(
                  child: Image.asset(
                    'assets/images/passwordSuccess.png',
                    height: 40.h,
                    width: 90.w,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Redirect to',
                    style: body2TextStyle.copyWith(fontWeight: FontWeight.w100),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      overlayColor:
                          WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: Text(
                      'Login Page',
                      style: body2TextStyle.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

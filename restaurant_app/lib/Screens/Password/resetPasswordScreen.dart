import 'package:flutter/material.dart';
import 'package:restaurant_app/Screens/User/login_screen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/input_fields/passwordField.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String restaurantId; // Added restaurantId parameter

  const ResetPasswordScreen({
    Key? key,
    required this.restaurantId, // Added restaurantId parameter
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String newPassword = '';
  String confirmPassword = '';

  bool obscureText = true;

  // void routeContinue() {
  //   {
  //     print('Password: $newPassword && Confirm Password: $confirmPassword');
  //     if (newPassword != confirmPassword) {
  //       ScaffoldMessenger.of(context)
  //         ..hideCurrentSnackBar()
  //         ..showSnackBar(
  //           SnackBar(
  //             duration: const Duration(seconds: 4),
  //             content: Text(
  //               'Entered passwords do not match',
  //               style: body4TextStyle,
  //             ),
  //             backgroundColor: colorFailure,
  //           ),
  //         );
  //     } else if (newPassword == '' || confirmPassword == '') {
  //       ScaffoldMessenger.of(context)
  //         ..hideCurrentSnackBar()
  //         ..showSnackBar(
  //           SnackBar(
  //             duration: const Duration(seconds: 4),
  //             content: Text(
  //               'Please enter data',
  //               style: body4TextStyle.copyWith(color: textWhite),
  //             ),
  //             backgroundColor: colorFailure,
  //           ),
  //         );
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => SuccessPage()),
  //       );
  //     }
  //     setState(
  //       () {
  //         newPassword = '';
  //         confirmPassword = '';
  //       },
  //     );
  //   }
  // }

  void resetPassword() async {
    if (newPassword == confirmPassword) {
      // var baseUrl = dotenv.env['BASE_URL'];
      var baseUrl = AppStrings.baseURL;
      final response = await http.post(
        Uri.parse('$baseUrl/auth/updateRestaurantById'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "_id": widget.restaurantId, // Use restaurantId here
          "updateData": {
            "password":
                newPassword, // Assuming you update the password field here
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['executed']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: colorSuccess,
              content: Text("Password Reset Successfully")));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Login_Screen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: colorFailure,
                content: Text(responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: colorFailure,
              content: Text("Failed to reset password")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: colorFailure,
          content: Text("Passwords do not match")));
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
                builder: (context) => Login_Screen(),
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
            PasswordField(
              labelText: 'New Password',
              onValueChanged: (value) {
                setState(() {
                  newPassword = value;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 3.h, bottom: 5.h),
              child: PasswordField(
                labelText: 'Confirm Password',
                onValueChanged: (value) {
                  setState(() {
                    confirmPassword = value;
                  });
                },
              ),
            ),
            mainButton(
              'Continue',
              textWhite,
              () => resetPassword(),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
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
              Text(
                'Your Password has been reset!',
                style: h1TextStyle.copyWith(color: primaryColor),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5.h),
              Center(
                child: Image.asset(
                  'assets/images/passwordSuccess.png',
                  height: 40.h,
                  width: 90.w,
                ),
              ),
              SizedBox(height: 5.h),
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
                        MaterialPageRoute(builder: (context) => Login_Screen()),
                      );
                    },
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
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

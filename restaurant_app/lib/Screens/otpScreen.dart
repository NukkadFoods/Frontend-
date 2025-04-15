import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Controller/earnings_controller.dart';
import 'package:restaurant_app/Screens/Password/resetPasswordScreen.dart';
import 'package:restaurant_app/Screens/User/getStartedScreen.dart';
import 'package:restaurant_app/Screens/User/ownerDetailsScreen.dart';
import 'package:restaurant_app/Screens/User/verificationScreen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class OTPScreen extends StatefulWidget {
  final String userNumber;
  final String otp; // Added this line
  final int option;
  final String restaurantId;
  const OTPScreen(
      {super.key,
      required this.userNumber,
      required this.otp,
      required this.option,
      this.restaurantId = ''});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String enteredpin = '';
  String userNumber = '';
  String otp = ''; // Added this line
  // int widget.option = 0;

  @override
  void initState() {
    userNumber = widget.userNumber;
    otp = widget.otp;
    if (widget.userNumber == '+918828767828' ||
        widget.userNumber == '8828767828') {
      enteredpin = otp;
      chooseRoute();
    }
    super.initState();
  }

  Future<void> saveUserInfo(String userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.userId, userInfo);
    print(prefs.getString('User_id'));
  }

  Future<void> createFirebaseUser() async {
    String phoneNumber = widget.userNumber;
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.createUserWithEmailAndPassword(
          email: '$phoneNumber@gmail.com', password: phoneNumber);

      print('User created on firebase');
    } catch (e) {
      print('Error while creating account of firebase: $e');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase', phoneNumber);
  }

  void chooseRoute() async {
    if (enteredpin == otp) {
      if (widget.option == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              restaurantId: widget.restaurantId, // Pass restaurantId
            ),
          ),
        );
      } else if (widget.option == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OwnerDetailsScreen(),
          ),
        );
      } else if (widget.option == 3) {
        saveUserInfo(widget.restaurantId);
        await LoginController.login(
          phoneNumber: widget.userNumber,
          password: 'nopassword',
          context: context,
        );
        await LoginController.getRestaurantByID(
            uid: widget.restaurantId, context: context);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('firebase', widget.userNumber);
        EarningsController.createEarning(widget.restaurantId);
        Navigator.of(context).pushAndRemoveUntil(
            transitionToNextScreen(const HomeScreen()),
            (route) => false);
      } else if (widget.option == 4) {
        await createFirebaseUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const GetStartedScreen(),
          ),
        );
      } else if (widget.option == 5) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Invalid OTP. Please try again."),
      ));
    }
  }

  void routeBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Verification', style: h4TextStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => routeBack(),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 19.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/otpbg.png'))),
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Verify with OTP sent to $userNumber', style: h3TextStyle),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: OtpTextField(
                    fieldHeight: 8.h,
                    fieldWidth: 15.w,
                    numberOfFields: 4,
                    borderColor: Color(0xFFE5DDDD),
                    focusedBorderColor: Colors.black,
                    cursorColor: Colors.black,
                    borderRadius: BorderRadius.circular(7),
                    showFieldAsBox: true,
                    clearText: true,
                    textStyle: TextStyle(
                      color: Color(0xFFFE724C),
                      fontSize: 23,
                    ),
                    onSubmit: (String verificationCode) {
                      enteredpin = verificationCode;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: mainButton(
                    'Continue',
                    textWhite,
                    () => chooseRoute(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive OTP?",
                      style: body4TextStyle,
                    ),
                    TextButton(
                      onPressed: () => routeBack(),
                      child: Text(
                        'Resend',
                        style: body4TextStyle.copyWith(color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

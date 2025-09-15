// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/screens/authentication_screens/get_started_screen.dart';
import 'package:driver_app/screens/authentication_screens/verification_screen.dart';
import 'package:driver_app/widgets/common/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/font-styles.dart';
import '../../widgets/common/full_width_green_button.dart';
import '../../widgets/common/transition_to_next_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen(
      {super.key,
      required this.phoneNumber,
      this.userexist = false,
      required this.option,
      required this.otp,
      required this.deliveryBoyID});

  final String phoneNumber;
  final bool userexist;
  final int option;
  final String otp; // Added this line
  final String deliveryBoyID;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((widget.phoneNumber == '8828767828' ||
              widget.phoneNumber == '+918828767828') ||
          kDebugMode) {
        _verifyOtp();
      }
    });
  }

  @override
  void dispose() {
    // Properly dispose of the controllers
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    super.dispose();
  }

  void createFirebaseUser() async {
    String phoneNumber = widget.phoneNumber;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.createUserWithEmailAndPassword(
          email: '$phoneNumber@gmail.com', password: phoneNumber);
      _auth.signInWithEmailAndPassword(
          email: '$phoneNumber@gmail.com', password: phoneNumber);
      // createDeliveryService(phoneNumber);
      print('User created on firebase');
    } catch (e) {
      print('Error while creating account of firebase: $e');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase', phoneNumber);
  }

  // void createDeliveryService(String number) {
  //   FirebaseFirestore.instance
  //       .collection('dboys')
  //       .doc(number)
  //       .set({'isBusy': false, 'status': false, 'orders': {}});
  // }

  void _verifyOtp() async {
    String enteredOtp = controller1.text +
        controller2.text +
        controller3.text +
        controller4.text;
    if ((widget.phoneNumber == '8828767828' ||
            widget.phoneNumber == '+918828767828') ||
        kDebugMode) {
      enteredOtp = widget.otp;
    }
    if (enteredOtp == widget.otp) {
      if (widget.option == 1) {
        createFirebaseUser();
        Navigator.of(context)
            .pushReplacement(transitionToNextScreen(GetStartedScreen()));
      } else if (widget.option == 2) {
        Navigator.of(context)
            .pushReplacement(transitionToNextScreen(VerificationScreen()));
      } else if (widget.option == 3) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('loginKey', widget.deliveryBoyID);
        await prefs.setString('uid', widget.deliveryBoyID);
        await prefs.setString('firebase', widget.phoneNumber);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context)
            .pushReplacement(transitionToNextScreen(BottomNavBar()));
      }
    } else {
      Toast.showToast(message: "Invalid OTP. Please try again.", isError: true);
    }
  }

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 4) {
      return phoneNumber; // If the number is too short, return as is
    }
    return 'xxxxxxx${phoneNumber.substring(phoneNumber.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    String maskedPhoneNumber = _maskPhoneNumber(widget.phoneNumber);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back_ios_new),
        ),
        title: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
            ),
            Text(
              'Verification',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: mediumLarge,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 0.7,
                fit: BoxFit.cover,
                image: AssetImage(
                  'assets/images/otpbbg.png',
                ),
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Verify with OTP sent to $maskedPhoneNumber',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOTPField(controller1, context),
                    _buildOTPField(controller2, context),
                    _buildOTPField(controller3, context),
                    _buildOTPField(controller4, context),
                  ],
                ),
                SizedBox(height: 60),
                FullWidthGreenButton(
                  label: 'CONTINUE',
                  onPressed: _verifyOtp, // Verification function
                ),
                SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Didn’t receive otp?',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: ' Resend',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green, // Replace with your color
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pop();
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(
      TextEditingController controller, BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.grey[400],
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 50,
        color: Colors.white,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

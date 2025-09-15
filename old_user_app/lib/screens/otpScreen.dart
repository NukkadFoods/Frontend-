import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/Screens/loginScreen.dart';
import 'package:user_app/Widgets/buttons/mainButton.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/screens/homeScreen.dart';
import 'package:user_app/utils/uniservice.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/loading_popup.dart';

class OTPScreen extends StatefulWidget {
  final String userNumber;
  final int option;
  final String otp;
  final String? uid;
  const OTPScreen(
      {super.key,
      required this.userNumber,
      required this.option,
      required this.otp,
      this.uid});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String enteredpin = '';
  String userNumber = '';
  int option = 0;
  String? saveAs;
  String? currentAddress;

  @override
  void initState() {
    super.initState();
    userNumber = widget.userNumber;
    option = widget.option;
  }

  // Function to show incorrect OTP toast
  void showIncorrectOtpToast() {
    Fluttertoast.showToast(
      msg: "Incorrect OTP",
      backgroundColor: Colors.white,
      textColor: Colors.red,
    );
  }

  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 4) {
      return phoneNumber; // If the number is too short, return as is
    }
    return 'xxxxxxx${phoneNumber.substring(phoneNumber.length - 3)}';
  }

  // Function to check OTP and route to different screens
  void chooseRoute() async {
    if (enteredpin == widget.otp) {
      if (option == 1) {
        SharedPrefsUtil().setString(AppStrings.userId, widget.uid!);
        Navigator.pushAndRemoveUntil(
          context,
          transitionToNextScreen(
            const HomeScreen(),
          ),
          (Route<dynamic> route) => false, // Remove all previous screens
        );
      } else if (option == 2) {
        final db =
            FirebaseFirestore.instance.collection('public').doc('nukkad-foods');
        //referral data retreival    reference=code
        Map<String, String> referralData = {
          'reference': "none",
          "referredby": 'UnKnown'
        };
        if (UniService.referralCode == null && UniService.executiveId == null) {
          try {
            final temp = (await db.get()).get('code');
            if (temp != null) {
              referralData['reference'] = temp;
              db.update({'code': null});
            }
          } catch (e) {
            print(e);
          }
        } else if (UniService.referralCode != null) {
          referralData['reference'] = UniService.referralCode!;
          // } else if (UniService.executiveId != null) {
          //   referralData['reference'] = UniService.executiveId!;
        }

        //Signup code
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showEnableLocationServiceDialog();
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          return;
        }

        Position position = await Geolocator.getCurrentPosition();
        await _getAddressFromLatLng(position);

        //old Code
        // Validate location
        final number = SharedPrefsUtil().getString('phoneNumber');
        // final name = SharedPrefsUtil().getString('UserName');
        // final email = SharedPrefsUtil().getString('UserEmail');
        // final geneder = SharedPrefsUtil().getString('gender');
        // final reference = jsonDecode(SharedPrefsUtil().getString('refer')!);
        final reference = referralData;

        showLoadingPopup(context, "Registering...");

        try {
          // String baseUrl = dotenv.env['BASE_URL'];
          String baseUrl = SharedPrefsUtil().getString('base_url')!;

          // Request data
          var reqData = {
            "username": "Nukkad",
            "email": "$number@email.com",
            "contact": number,
            "password": 'nopassword', // Securely handle passwords
            "addresses": [
              {
                "address": currentAddress ?? '',
                "latitude": position.latitude,
                "longitude": position.longitude,
                "area": 'temp',
                "hint": 'temp',
                "saveAs": saveAs ?? "Home",
              }
            ],
            "gender": "unknown",
            "userImage": "www.image.com",
            "referredby":
                reference, // Replace with actual image URL or buffer data
          };

          // Encode request body
          String requestBody = jsonEncode(reqData);
          print('$reqData');
          // Send POST request
          final response = await http.post(
            Uri.parse('$baseUrl/auth/userSignUp'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: requestBody,
          );
          print(response.body);
          // Check for success
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            print(response.statusCode);
            print(response.body);
            // Check if executed field is true
            if (responseData != null && responseData['executed']) {
              final response = await http.post(
                  Uri.parse('$baseUrl/auth/userLogin'),
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(
                      {"contact": number, "password": "nopassword"}));
              if (response.statusCode == 200) {
                final String uid = jsonDecode(response.body)['uid'];
                await SharedPrefsUtil().setString(AppStrings.userId, uid);
                await WalletController.createWallet(context, "Nukkad");
                // Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  transitionToNextScreen(
                    const HomeScreen(),
                  ),
                  (Route<dynamic> route) =>
                      false, // Remove all previous screens
                );
              } else {
                // Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  transitionToNextScreen(
                    const LoginScreen(),
                  ),
                  (Route<dynamic> route) =>
                      false, // Remove all previous screens
                );
              }
              return;
              // Fluttertoast.showToast(
              //     msg: 'Signup Successful. Please Login.',
              //     backgroundColor: textWhite,
              //     textColor: colorSuccess);
              // Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              Navigator.of(context).pop();
              Fluttertoast.showToast(
                  msg: 'Something went wrong',
                  backgroundColor: textWhite,
                  textColor: primaryColor);
            }
          } else {
            // Handle non-200 responses
            Navigator.of(context).pop();
            Fluttertoast.showToast(
                msg: 'Something went wrong',
                backgroundColor: textWhite,
                textColor: primaryColor);
          }
        } catch (e) {
          // Handle network or API exceptions
          Fluttertoast.showToast(
              msg: 'Network Error or Server Issue',
              backgroundColor: textWhite,
              textColor: primaryColor,
              gravity: ToastGravity.CENTER);
        }

        // Navigator.pushReplacement(
        //   context,
        //   transitionToNextScreen(
        //     const RegistrationScreen(),
        //   ),
        // );
      }
    } else {
      // Show toast for incorrect OTP
      showIncorrectOtpToast();
    }
  }

  // Function to route back to login
  void routeLogin() {
    Navigator.pushReplacement(
      context,
      transitionToNextScreen(
        const LoginScreen(),
      ),
    );
  }

  void _showEnableLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Location services are disabled. Please enable them in your device settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      saveAs = place.name ?? 'Home';
      setState(() {
        currentAddress = "${place.street}, ${place.locality}, ${place.country}";
      });

      print(
          'Updated Position: Latitude ${position.latitude}, Longitude ${position.longitude}');
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: 'Something went wrong',
          backgroundColor: textWhite,
          textColor: primaryColor);
    }
  }

  // Future<void> userSignUp() async {
  //    finally {
  //     // Navigator.of(context).pop();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    String maskedPhoneNumber = _maskPhoneNumber(widget.userNumber);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (userNumber == "+918828767828" || userNumber == "8828767828") {
    //     enteredpin = widget.otp;
    //     chooseRoute();
    //   }
    // });
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Verification',
            style: h4TextStyle.copyWith(
                color: isdarkmode ? textWhite : textBlack)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => routeLogin(),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 19.sp,
            color: isdarkmode ? textWhite : Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            child:
                Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Verify with OTP sent to $maskedPhoneNumber',
                      style: h4TextStyle.copyWith(
                          color: isdarkmode ? textWhite : textBlack)),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: OtpTextField(
                      fieldHeight: 7.h,
                      fieldWidth: 14.w,
                      numberOfFields: 4,
                      borderColor: Colors.grey.shade600,
                      focusedBorderColor: primaryColor,
                      cursorColor: primaryColor,
                      borderRadius: BorderRadius.circular(7),
                      showFieldAsBox: true,
                      clearText: true,
                      textStyle:
                          TextStyle(color: isdarkmode ? textWhite : textBlack),
                      onSubmit: (String verificationCode) {
                        setState(() {
                          enteredpin = verificationCode;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child:
                        mainButton('Continue', textWhite, () => chooseRoute()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive OTP?",
                        style: body4TextStyle.copyWith(
                            color: isdarkmode ? textWhite : textBlack),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:math';

// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/Widgets/buttons/mainButton.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/strings.dart';
import 'package:user_app/map/map.dart';
import 'package:user_app/screens/otpScreen.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/customs/customphonefirld.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.hideSkip});
  final bool? hideSkip;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userNumber = '';
  String userPassword = '';
  bool isLoading = false;
  String phonenumberwithcountrycode = '';
  String countrycode = '+91';
  String uid = '';
  String DLTTemplateId = '', preMsg = '', postMsg = '';

  final CustomTextController phoneController = CustomTextController();
  @override
  void initState() {
    super.initState();
    phoneController.addListener(
      () {
        String value = phoneController.text;
        if (value.length > 10) {
          value = value.replaceAll(" ", '');
          if (value.startsWith("+91")) {
            value = value.substring(3);
          } else if (value.startsWith("91")) {
            value = value.substring(2);
          }
          if (value.length > 10) {
            value = value.substring(0, 10);
          }
          phoneController.text = value;
        }
        if (value.length > 8) {
          phoneController.textColor =
              value.length < 10 ? Colors.black : primaryColor;
          if (mounted) {
            print('Setstate called');
            setState(() {});
          }
        }
      },
    );
    // getAppTrackingPermission();
    getOtpCreds();
  }

  Future<void> getOtpCreds() async {
    try {
      final data = (await FirebaseFirestore.instance
              .collection('constants')
              .doc('common')
              .get())
          .data();
      DLTTemplateId = data!['DLTTemplateId'];
      preMsg = data['preMsg'];
      postMsg = data['postMsg'];
    } catch (e) {
      print(e);
    }
  }

  // void getAppTrackingPermission() async {
  //   if (defaultTargetPlatform == TargetPlatform.iOS) {
  //     try {
  //       final status =
  //           await AppTrackingTransparency.trackingAuthorizationStatus;
  //       if (status == TrackingStatus.notDetermined) {
  //         AppTrackingTransparency.requestTrackingAuthorization();
  //       }
  //     } catch (e) {}
  //   }
  // }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> userSignIn() async {
    setState(() {
      isLoading = true;
    });
    String generateOTP() {
      Random random = Random();
      return (1000 + random.nextInt(9000)).toString();
    }

    userNumber = phoneController.text.trim();
    if (userNumber != '') {
    } else {
      Fluttertoast.showToast(
          msg: 'Please enter mobile number !!',
          backgroundColor: textWhite,
          textColor: primaryColor);
    }

    String otp = generateOTP();
    print(otp);

    if (!userNumber.startsWith(countrycode)) {
      phonenumberwithcountrycode = '$countrycode$userNumber';
    } else {
      phonenumberwithcountrycode = userNumber;
    }

    try {
      // var baseUrl = dotenv.env['BASE_URL'];
      String baseUrl = SharedPrefsUtil().getString('base_url')!;
      String otpBaseUrl = "https://www.smsgatewayhub.com/api/mt/SendSMS?";
      var reqData = {
        "contact": phonenumberwithcountrycode,
        "password": "nopassword"
      };
      String requestBody = jsonEncode(reqData);
      final response = await http.post(Uri.parse('$baseUrl/auth/userLogin'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: requestBody);
      print(response.statusCode);
      print(phonenumberwithcountrycode);
      if (DLTTemplateId.isEmpty) {
        await getOtpCreds();
      }
      http.Response otpResponse;
      if (phonenumberwithcountrycode != "+919076044682" &&
          phonenumberwithcountrycode != "+918828767828") {
        otpResponse = await http.post(
          Uri.parse(otpBaseUrl), // Ensure this is the correct endpoint
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "Account": {
              "APIkey": "nThnVXGnSkyDLK2gUnCung",
              "SenderId": "Nukadd",
              "Channel": "2",
              "DCS": "0",
              "SchedTime": null,
              "GroupId": null,
              "EntityId": "1701172751226780335"
            },
            "Messages": [
              {
                "Text": "$preMsg $otp. $postMsg",
                "DLTTemplateId": DLTTemplateId,
                "Number": phonenumberwithcountrycode.substring(1)
              }
            ]
          }),
        );
      } else {
        otpResponse = http.Response(jsonEncode({"ErrorCode": "000"}), 200);
      }

      if (!(otpResponse.statusCode == 200 &&
          jsonDecode(otpResponse.body)["ErrorCode"] == "000")) {
        throw Exception('Failed to send OTP');
      }
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData['message']);
        if (responseData != null && responseData['executed']) {
          uid = responseData['uid'] ?? '';
          saveUserInfo(responseData['uid']);
          Fluttertoast.showToast(
              msg: 'User Found Succefully',
              backgroundColor: textWhite,
              textColor: colorSuccess,
              gravity: ToastGravity.BOTTOM);

          setState(() {
            isLoading = false;
          });
          savephoneNumber(phonenumberwithcountrycode);

          Navigator.push(
              context,
              transitionToNextScreen(
                OTPScreen(
                  userNumber: phonenumberwithcountrycode,
                  option: 1,
                  otp: otp,
                  uid: responseData['uid'],
                ),
              ));
        } else {
          setState(() {
            isLoading = false;
          });
          savephoneNumber(phonenumberwithcountrycode);
          Navigator.push(
              context,
              transitionToNextScreen(
                OTPScreen(
                  userNumber: phonenumberwithcountrycode,
                  option: 2,
                  otp: otp,
                ),
              ));
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'Something went wrong please try again later !!',
            backgroundColor: textWhite,
            textColor: primaryColor);
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  Future<void> saveUserInfo(userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('UserId', userInfo);
  }

  Future<void> savephoneNumber(phonenumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('streakCount');
    await prefs.setString('phoneNumber', phonenumber);
    await prefs.setString(AppStrings.mobilenumber, phonenumber);
    WalletController.createWallet(context, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width,
          child: Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.cover,
          )),
      SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: widget.hideSkip == true
                      ? const SizedBox.shrink()
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(transitionToNextScreen(const MapsScreen(
                              loginSkipped: true,
                              add: true,
                            )));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.white)),
                              minimumSize: Size.zero),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/background.png')),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign in or Sign up',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                            child:
                                CustomPhoneField(controller: phoneController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'You will receive an SMS verification that may apply message and data rates.',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    isLoading
                        ? const CircularProgressIndicator(
                            color: primaryColor,
                          )
                        : mainButton('SIGN IN', textWhite, userSignIn)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]));
  }
}

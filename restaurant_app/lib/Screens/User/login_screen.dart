import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Screens/User/verificationScreen.dart';
import 'package:restaurant_app/Screens/otpScreen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/customs/custom_phone_field.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Login_ScreenState();
  }
}

class _Login_ScreenState extends State<Login_Screen> {
  final CustomTextController ownerPhoneController = CustomTextController();
  bool isLoading = false;
  String errorMessage = '';
  String enteredNumber = '';
  String countryCode = '+91';
  String phoneNumberWithCountryCode = '';
  String DLTTemplateId = '', preMsg = '', postMsg = '';

  @override
  void initState() {
    super.initState();
    ownerPhoneController.addListener(
      () {
        String value = ownerPhoneController.text;
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
          ownerPhoneController.text = value;
        }
        if (value.length > 8) {
          ownerPhoneController.textColor =
              value.length < 10 ? Colors.black : primaryColor;
          if (mounted) {
            print('Setstate called');
            setState(() {});
          }
        }
      },
    );
    getOtpCreds();
    getAppTrackingPermission();
  }

  @override
  void dispose() {
    ownerPhoneController.dispose();
    super.dispose();
  }

  void getAppTrackingPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          AppTrackingTransparency.requestTrackingAuthorization();
        }
      } catch (e) {}
    }
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

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = ''; // Reset the error message on a new login attempt
    });

    enteredNumber = ownerPhoneController.text;
    phoneNumberWithCountryCode = countryCode + enteredNumber;

    try {
      // var baseUrl = dotenv.env['BASE_URL'];
      String baseUrl = AppStrings.baseURL;
      String otpBaseUrl = "https://www.smsgatewayhub.com/api/mt/SendSMS?";
      if (baseUrl.isEmpty) {
        throw Exception('Base URL not configured');
      }

      String generateOTP() {
        Random random = Random();
        return (1000 + random.nextInt(9000)).toString();
      }

      String otp = generateOTP();
      print(otp);
      saveUsermobile(phoneNumberWithCountryCode);

      // Check the restaurant UID by phone number
      final verifyResponse = await http.post(
        Uri.parse('$baseUrl/auth/getRestaurantUIDbyPhoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phoneNumber": phoneNumberWithCountryCode,
        }),
      );

      final verifyData = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && verifyData['executed']) {
        var restaurantId = verifyData['uid'] ?? '';

        // Perform login with the phone number
        final loginResponse = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "phoneNumber": phoneNumberWithCountryCode,
            'password': "nopassword", // Assuming no password is required
          }),
        );

        if (loginResponse.statusCode == 200) {
          final verificationStatus = jsonDecode(loginResponse.body);

          if (verificationStatus['executed'] == true) {
            var status = verificationStatus['status'];

            if (status == 'unverified') {
              Navigator.push(
                context,
                transitionToNextScreen(VerificationScreen()),
              );
            } else if (status == 'Invalid') {
              Navigator.push(
                context,
                transitionToNextScreen(VerificationScreen()),
              );
            } else {
              // Send OTP via SMS
              http.Response otpResponse;
              if (DLTTemplateId.isEmpty) {
                getOtpCreds();
              }
              if (phoneNumberWithCountryCode != "+918828767828") {
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
                        "Number": phoneNumberWithCountryCode.substring(1)
                      }
                    ]
                  }),
                );
              } else {
                otpResponse =
                    http.Response(jsonEncode({"ErrorCode": "000"}), 200);
              }
              print(otpResponse.statusCode);
              print(otpResponse.body);
              if (!(otpResponse.statusCode == 200 &&
                  jsonDecode(otpResponse.body)["ErrorCode"] == "000")) {
                throw Exception('Failed to send OTP');
              }

              Navigator.push(
                context,
                transitionToNextScreen(OTPScreen(
                  userNumber: phoneNumberWithCountryCode,
                  otp: otp,
                  option: 3,
                  restaurantId: restaurantId,
                )),
              );
            }
            print('Verification status: $status');
          } else {
            print('OTP sending process was not executed.');
          }
        } else {
          // Handle non-200 response status codes
          print('Login failed. HTTP Status Code: ${loginResponse.statusCode}');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // Send OTP via SMS
        http.Response otpResponse;
        if (DLTTemplateId.isEmpty) {
          await getOtpCreds();
        }
        if (phoneNumberWithCountryCode != "+918828767828") {
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
                  "Number": phoneNumberWithCountryCode.substring(1)
                }
              ]
            }),
          );
        } else {
          otpResponse = http.Response(jsonEncode({"ErrorCode": "000"}), 200);
        }
        print(otpResponse.statusCode);
        print(otpResponse.body);
        if (!(otpResponse.statusCode == 200 &&
            jsonDecode(otpResponse.body)["ErrorCode"] == "000")) {
          throw Exception('Failed to send OTP');
        }

        Navigator.push(
          context,
          transitionToNextScreen(
            OTPScreen(
              userNumber: enteredNumber,
              otp: otp,
              option: 4,
              restaurantId: '', // No restaurant ID available
            ),
          ),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $error'; // Set an error message
        debugPrint(errorMessage);
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveUsermobile(String Mobilenumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('contact_number', Mobilenumber);
    print(prefs.getString(Mobilenumber));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Container(
        height: MediaQuery.sizeOf(context).height * 0.8,
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
              height: MediaQuery.sizeOf(context).height * 0.8,
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: Image.asset('assets/images/logo.png')),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/otpbg.png')),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'sign in or sign up',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    //   child: PhoneField(
                    // controller: ownerPhoneController,
                    // fontSize: 18,
                    // onPhoneNumberChanged: (String number) {
                    //   setState(() {
                    //     enteredNumber = number;
                    //   });
                    // },)
                    child: CustomPhoneField(controller: ownerPhoneController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: const EdgeInsets.only(left: 10),
                child: const Text(
                  'You will receive an SMS verification that may apply message and data rates.',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12,
                    color: textGrey1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              mainButton('SIGN IN', textWhite, signIn, isLoading: isLoading)
            ],
          ),
        ),
      ),
    ]));
  }
}

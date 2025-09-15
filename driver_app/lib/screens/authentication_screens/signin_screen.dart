import 'dart:convert';
import 'dart:math';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/screens/authentication_screens/banned_screen.dart';
import 'package:driver_app/screens/authentication_screens/otp_screen.dart';
import 'package:driver_app/screens/authentication_screens/verification_screen.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/common/custom_phone_field.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() {
    return SignInScreenState();
  }
}

class SignInScreenState extends State<SignInScreen> {
  final CustomTextController _mobileNumberController = CustomTextController();
  bool _isSigningIn = false;
  String countryCode = '+91';
  String phoneNumberWithCountryCode = '';
  bool verifcation = false;
  var OTP;
  var DeliveryBoyId;
  String DLTTemplateId = '', preMsg = '', postMsg = '';

  @override
  void initState() {
    super.initState();
    _mobileNumberController.addListener(
      () {
        String value = _mobileNumberController.text;
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
          _mobileNumberController.text = value;
        }
        if (value.length > 8) {
          _mobileNumberController.textColor =
              value.length < 10 ? Colors.black : colorGreen;
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

  String generateOTP() {
    Random random = Random();
    int otp = random.nextInt(10000);
    return otp.toString().padLeft(4, '0');
  }

  Future<void> _signIn() async {
    if (_isSigningIn) return;

    setState(() {
      _isSigningIn = true;
    });

    final String contact = _mobileNumberController.text.trim();

    if (contact.isEmpty) {
      Toast.showToast(
          message: "Please fill all required fields", isError: true);
      setState(() {
        _isSigningIn = false;
      });
      return;
    }

    try {
      String otp = generateOTP();
      OTP = otp;
      print('Generated OTP: $otp');

      if (!contact.startsWith(countryCode)) {
        phoneNumberWithCountryCode = '$countryCode$contact';
      } else {
        phoneNumberWithCountryCode = contact;
      }

      // final String baseurl = dotenv.env['BASE_URL']!;
      final String baseurl = AppStrings.baseURL;
      final String otpBaseUrl = "https://www.smsgatewayhub.com/api/mt/SendSMS?";

      saveUsermobile(contact);

      // Proceed with checking if user exists
      final response = await http.post(
        Uri.parse('$baseurl/auth/getDeliveryBoyUIDbyPhoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phoneNumber": contact,
        }),
      );

      print('Login Response Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['executed']) {
            var deliveryBoyId = responseData['uid'] ?? '';
            await getDeliveryBoyById(
                id: deliveryBoyId,
                otp: otp,
                baseurl: baseurl,
                otpBaseUrl: otpBaseUrl);
            DeliveryBoyId = deliveryBoyId;
            // Update the OTP screen with user existence information
          }
        } catch (e) {
          Toast.showToast(
              message: 'Invalid response format from server', isError: true);
        }
      } else {
        if (DLTTemplateId.isEmpty) {
          await getOtpCreds();
        }
        http.Response otpResponse;
        if (phoneNumberWithCountryCode != "+918828767828"&&!kDebugMode) {
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

        if (otpResponse.statusCode == 200 &&
            jsonDecode(otpResponse.body)["ErrorCode"] == "000") {
          Navigator.of(context).push(
            transitionToNextScreen(
              OtpScreen(
                phoneNumber: _mobileNumberController.text,
                otp: otp,
                deliveryBoyID: '',
                userexist: false,
                option: 1,
              ),
            ),
          );
        } else {
          Toast.showToast(message: 'Server Error', isError: true);
          print(otpResponse.body);
        }
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: 'Unstable Internet!', isError: true);
      }
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  Future<void> saveUsermobile(String Mobilenumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('contact_number', Mobilenumber);
    print(prefs.getString(Mobilenumber));
  }

  Future<void> getDeliveryBoyById(
      {String? id, String? otp, String? baseurl, String? otpBaseUrl}) async {
    try {
      final response =
          await http.get(Uri.parse('$baseurl/auth/getDeliveryBoyById/$id'));

      if (response.statusCode == 200) {
        // Parse the response body
        final responseData = jsonDecode(response.body);

        // Extract and print the status information

        var status = responseData['deliveryBoy']['status'];

        if (responseData['deliveryBoy']['isBanned'] == true) {
          Navigator.of(context)
              .pushReplacement(transitionToNextScreen(const BannedScreen()));
        }

        if (status == "verified") {
          // setState(() {
          verifcation = true;
          if (DLTTemplateId.isEmpty) {
            await getOtpCreds();
          }
          http.Response otpResponse;
          if (phoneNumberWithCountryCode != "+918828767828" && !kDebugMode) {
            otpResponse = await http.post(
              Uri.parse(otpBaseUrl!), // Ensure this is the correct endpoint
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

          // print('sms sent');
          if (otpResponse.statusCode == 200 &&
              jsonDecode(otpResponse.body)["ErrorCode"] == "000") {
            print('saving user data');
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString(
                'deliveryBoyData', jsonEncode(responseData['deliveryBoy']));
            print('saved user data');
            Navigator.of(context).push(
              transitionToNextScreen(
                OtpScreen(
                  phoneNumber: _mobileNumberController.text,
                  otp: OTP,
                  deliveryBoyID: responseData['deliveryBoy']['_id'],
                  userexist: true,
                  option: 3,
                ),
              ),
            );
          } else {
            Toast.showToast(message: 'Server Error', isError: true);
            print(otpResponse.body);
          }
        } else {
          Navigator.of(context).push(
            transitionToNextScreen(VerificationScreen()),
          );
        }
        print('Status: $status');
      } else {
        // Handle non-200 status codes
        print(
            'Failed to load delivery boy details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors
      if (error == http.ClientException) {
        Toast.showToast(message: 'Unstable Internet!', isError: true);
      }
      print('An error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/splashbg.png'))),
          ),
          // Bottom White Section with form fields
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/otpbbg.png')),
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
                          child: CustomPhoneField(
                        controller: _mobileNumberController,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: const Text(
                      'You will receive an SMS verification that may apply message and data rates.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FullWidthGreenButton(
                      label: 'SIGN IN',
                      onPressed: _signIn,
                      isLoading: _isSigningIn)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

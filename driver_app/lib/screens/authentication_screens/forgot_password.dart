import 'dart:math';
import 'dart:convert';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:http/http.dart' as http;
import 'package:driver_app/utils/colors.dart';

import 'package:driver_app/screens/authentication_screens/otp_screen.dart';
import 'package:flutter/material.dart';

import '../../utils/font-styles.dart';
import '../../widgets/common/custom_phone_field.dart';
import '../../widgets/common/full_width_green_button.dart';
import '../../widgets/common/transition_to_next_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  CustomTextController _mobileNumberController = CustomTextController();

  String deliveryBoyId = '';

  bool _isLoading = false;

  @override
  void dispose() {
    _mobileNumberController.dispose();
    super.dispose();
  }

  String generateOTP() {
    Random random = Random();
    int otp = random.nextInt(10000);
    return otp.toString().padLeft(4, '0');
  }

  Future<void> getDeliveryBoyUID(String phoneNumber) async {
    // final String baseUrl = dotenv.env['BASE_URL']!;
    final String baseUrl = AppStrings.baseURL;
    final response = await http.post(
      Uri.parse('$baseUrl/auth/getDeliveryBoyUIDbyPhoneNumber'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phoneNumber': '+91$phoneNumber',
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['executed'] && responseData['uid'] != null) {
        deliveryBoyId = responseData['uid'];
      } else {
        throw Exception('Delivery boy not found');
      }
    } else {
      throw Exception('Failed to fetch UID');
    }
  }

  Future<void> sendOtp(String phoneNumber, String otp) async {
    // final String baseUrl = dotenv.env['BASE_URL']!;
    final String baseUrl = AppStrings.baseURL;
    print(phoneNumber);
    final response = await http.post(
      Uri.parse('$baseUrl/sms/sendSMS'), // Update with your backend URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'to': '+91$phoneNumber',
        'body': 'Your OTP is $otp',
      }),
    );

    // if (response.statusCode == 200) {
    //   var responseData = jsonDecode(response.body);
    //   deliveryBoyId = responseData['deliveryBoyId'];
    // }

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP');
    }
  }

  void _sendOtpForForgotPassword() async {
    if (_mobileNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: colorRed,
        content: Text("Please enter your mobile number"),
      ));
      return;
    }

    if (_isLoading) {
      return; // Prevent multiple clicks
    }

    setState(() {
      _isLoading = true;
    });

    String otp = generateOTP();
    print(otp);

    try {
      await getDeliveryBoyUID(_mobileNumberController.text);
      await sendOtp(_mobileNumberController.text, otp);
      Navigator.of(context).push(
        transitionToNextScreen(
          OtpScreen(
            phoneNumber: _mobileNumberController.text,
            userexist: false,
            otp: otp,
            deliveryBoyID: deliveryBoyId,
            option: 5,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Failed to send OTP"),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_ios_new)),
        title: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
            ),
            Text(
              'Forgot Password',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: mediumLarge,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 60,
            ),
            Text(
              textAlign: TextAlign.center,
              'Verify your phone number xxxxxx999 linked to your account and enter otp to recover your account.',
              style: TextStyle(
                fontSize: mediumSmall,
              ),
            ),
            SizedBox(
              height: 60,
            ),
            CustomPhoneField(
              controller: _mobileNumberController,
            ),
            SizedBox(
              height: 80,
            ),
            FullWidthGreenButton(
              label: 'SEND OTP',
              // onPressed: () {
              //   Navigator.of(context).push(transitionToNextScreen(OtpScreen()));
              // },
              onPressed: _sendOtpForForgotPassword, // Disable button if loading
              isLoading: _isLoading,
            )
          ],
        ),
      ),
    );
  }
}

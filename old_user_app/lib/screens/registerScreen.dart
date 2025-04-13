import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/buttons/mainButton.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/conditionsWidget.dart';
import 'package:user_app/screens/locationSetupScreen.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

import 'package:user_app/widgets/input_fields/textInputField.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isLoading = false;
  String userName = '';
  String userEmail = '';
  // String userNumber = '';
  String selectedGender = ''; // Gender variable
  final TextEditingController phoneController = TextEditingController();
  final userNameController = TextEditingController();
  final userEmailController = TextEditingController();
  bool obscureText = true;

  // Function to store user data in SharedPreferences
  Future<void> saveUserInfo(
      String username, String useremail, String gender) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('UserName', username);
    await prefs.setString('UserEmail', useremail);
    await prefs.setString('gender', gender);

    print(gender); // Save gender
  }

  // Function to handle the sign-up process
  routeSignUp() {
    if (userName != '' && userEmail != '' && selectedGender != '') {
      userName = userNameController.text;
      userEmail = userEmailController.text;
      saveUserInfo(userName, userEmail, selectedGender); // Save with gender
      Navigator.of(context)
          .push(transitionToNextScreen(const LocationSetupScreen(
        isAdd: false,
      )));
    } else {
      Fluttertoast.showToast(
          msg: 'Please enter all details .!',
          backgroundColor: textWhite,
          textColor: primaryColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/background.png'), // Path to background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Form content
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(5.w, 10.h, 5.w, 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Register', style: h3TextStyle),
                SizedBox(height: 3.h),
                textInputField('Name', userNameController, (String name) {
                  setState(() {
                    userName = name;
                  });
                }, context, capitalization: TextCapitalization.words),
                SizedBox(height: 2.h),
                textInputField('Email', userEmailController, (String email) {
                  setState(() {
                    userEmail = email;
                  });
                }, context),
                SizedBox(height: 3.h),
                Text('Select your gender', style: h5TextStyle),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: 'male',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                          activeColor: primaryColor, // Set selected color
                        ),
                        const Text('Male'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: 'female',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                          activeColor: primaryColor, // Set selected color
                        ),
                        const Text('Female'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: 'other',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                          activeColor: primaryColor, // Set selected color
                        ),
                        const Text('Rather not say'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: colorFailure,
                        ),
                      )
                    : mainButton('NEXT', textWhite, () => routeSignUp()),
                SizedBox(height: 1.h),
                privacyPolicyLinkAndTermsOfService(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

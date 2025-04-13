import 'package:driver_app/screens/authentication_screens/get_started_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/font-styles.dart';
import '../../widgets/common/custom_phone_field.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/full_width_green_button.dart';
import '../../widgets/common/transition_to_next_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'signin_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  CustomTextController _phoneNoController = CustomTextController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String contactNumber = '';
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _addListeners();
    getContactNumber();
  }

  void _addListeners() {
    _nameController
        .addListener(() => saveUserInfoKeyValue('name', _nameController.text));
    _emailController.addListener(
        () => saveUserInfoKeyValue('email', _emailController.text));
    _phoneNoController.addListener(() {
      String enteredNumber = _phoneNoController.text;
      String countryCode = '+91'; // Replace with your desired country code

      // Check if the country code is already present
      if (!enteredNumber.startsWith(countryCode)) {
        contactNumber = '$countryCode$enteredNumber';
      } else {
        contactNumber = enteredNumber;
      }

      saveUserInfoKeyValue('contact', contactNumber);
    });
    _passwordController.addListener(
        () => saveUserInfoKeyValue('password', _passwordController.text));
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoStr = prefs.getString('user_info');
    if (userInfoStr != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoStr);
      setState(() {
        _nameController.text = userInfo['name'] ?? '';
        _emailController.text = userInfo['email'] ?? '';
        // _phoneNoController.text = userInfo['contact'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneNoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
    });
  }

  Future<void> getContactNumber() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedContactNumber = prefs.getString('contact_number');
      if (savedContactNumber != null) {
        print('Saved contact number: $savedContactNumber');
        setState(() {
          contactNumber = savedContactNumber;
          _phoneNoController.text = savedContactNumber;
        });
      } else {
        print('No contact number found in SharedPreferences');
      }
    } catch (e) {
      print('Error retrieving contact number: $e');
    }
  }

  Future<void> saveUserInfoKeyValue(String key, dynamic value) async {
    Map<String, dynamic> newData = {key: value};
    await saveUserInfo(newData);
  }

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userInfoStr = jsonEncode(userInfo); // Convert Map to JSON string
    await prefs.setString('user_info', userInfoStr); // Store JSON string
    print('Stored user info: $userInfoStr');
  }

  void _handleSignUp() async {
    if (_isLoading) return; // Prevent multiple clicks

    // Check if any field is empty
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        contactNumber.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: colorBrightRed,
        ),
      );
      return;
    }

    // Validate passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: colorBrightRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> userData = {
        'name': 'name',
        'email': 'mailid',
        'contact': _phoneNoController.text,
        'password': 'nopassword',
      };

      await saveUserInfo(userData);

      Navigator.of(context).push(
        transitionToNextScreen(GetStartedScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign up.'),
          backgroundColor: colorBrightRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
              ),
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: extraLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              CustomTextField(
                label: 'NAME',
                controller: _nameController,
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                label: 'EMAIL',
                controller: _emailController,
              ),
              SizedBox(
                height: 20,
              ),
              CustomPhoneField(controller: _phoneNoController),
              SizedBox(
                height: 5,
              ),
              Text(
                'An otp will be sent to your registered mobile number',
                style: TextStyle(
                  fontSize: small,
                  color: colorGray,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                label: 'PASSWORD',
                controller: _passwordController,
                isObscured: _isPasswordObscured,
                icon: IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: colorGreen,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                label: 'CONFIRM PASSWORD',
                controller: _confirmPasswordController,
                isObscured: _isConfirmPasswordObscured,
                icon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: colorGreen,
                  ),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              FullWidthGreenButton(
                label: 'SIGN UP', onPressed: _handleSignUp,
                isLoading: _isLoading,
                // Navigator.of(context)
                // .push(transitionToNextScreen(GetStartedScreen()));
                // }),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(transitionToNextScreen(SignInScreen()));
                  },
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account?',
                          style: TextStyle(
                              fontSize: mediumSmall, color: colorGray),
                        ),
                        TextSpan(
                          text: ' Sign in',
                          style: TextStyle(
                            fontSize: mediumSmall,
                            color: colorGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              // Center(
              //   child: Text('Sign in with',
              //       style: TextStyle(fontSize: mediumSmall, color: colorGray)),
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Image.asset('assets/images/googlelogo.png'),
              //     SizedBox(
              //       width: 10,
              //     ),
              //     Image.asset('assets/images/facebooklogo.png'),
              //     SizedBox(
              //       width: 10,
              //     ),
              //     Image.asset('assets/images/twitterlogo.png'),
              //   ],
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'By clicking Sign Up, I agree to the',
                        style: TextStyle(
                            fontSize: mediumSmall, color: Colors.black),
                      ),
                      TextSpan(
                        text: ' terms of service',
                        style: TextStyle(
                          fontSize: mediumSmall,
                          color: colorGreen,
                        ),
                      ),
                      TextSpan(
                        text: ' and',
                        style: TextStyle(
                            fontSize: mediumSmall, color: Colors.black),
                      ),
                      TextSpan(
                        text: ' privacy policy',
                        style: TextStyle(
                          fontSize: mediumSmall,
                          color: colorGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

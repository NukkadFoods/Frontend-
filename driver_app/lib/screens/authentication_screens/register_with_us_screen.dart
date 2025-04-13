import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/screens/authentication_screens/documentation_screen.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/common/custom_phone_field.dart';
import 'package:driver_app/widgets/common/custom_text_field.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/grey_container.dart';
import 'package:driver_app/widgets/common/info_container.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'dart:math'; // Add this import
// Add this import
// Add this import
import 'package:intl/intl.dart'; // Add this import for date formatting

import '../../utils/font-styles.dart';

class RegisterWithUsScreen extends StatefulWidget {
  const RegisterWithUsScreen({super.key});

  @override
  RegisterWithUsScreenState createState() => RegisterWithUsScreenState();
}

class RegisterWithUsScreenState extends State<RegisterWithUsScreen> {
  String _selectedGender = 'Male'; // 0: Male, 1: Female, 2: Other
  // DateTime? _selectedDate;
  bool showError = false;

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final CustomTextController _phoneNumberController = CustomTextController();
  final CustomTextController _whatsappNumberController = CustomTextController();
  final CustomTextController _secondaryNumberController =
      CustomTextController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _bankBranchCodeController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // final FirebaseAuth _auth = FirebaseAuth.instance;?

  String phoneNumberWithCountryCode = '';
  String whatsappNumberWithCountryCode = '';
  String alternateNumberWithCountryCode = '';
  bool _isRegistering = false;

  bool _sameAsMobileNumber = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _addListeners();
    getContactNumber();
  }

  Future<void> getContactNumber() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedContactNumber = prefs.getString('contact_number');
      if (savedContactNumber != null) {
        print('Saved contact number: $savedContactNumber');
        setState(() {
          phoneNumberWithCountryCode = savedContactNumber;
          _phoneNumberController.text = savedContactNumber;
        });
      } else {
        print('No contact number found in SharedPreferences');
      }
    } catch (e) {
      print('Error retrieving contact number: $e');
    }
  }

  // Future<void> getContactNumber() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? savedContactNumber = prefs.getString('contact_number');
  //     if (savedContactNumber != null) {
  //       print('Saved contact number: $savedContactNumber');
  //       setState(() {
  //         phoneNumberWithCountryCode = savedContactNumber;
  //         _phoneNumberController.text = savedContactNumber;
  //       });
  //     } else {
  //       print('No contact number found in SharedPreferences');
  //     }
  //   } catch (e) {
  //     print('Error retrieving contact number: $e');
  //   }
  // }

  void _addListeners() {
    _firstNameController.addListener(
        () => saveUserInfoKeyValue('firstName', _firstNameController.text));
    _middleNameController.addListener(
        () => saveUserInfoKeyValue('middleName', _middleNameController.text));
    _lastNameController.addListener(
        () => saveUserInfoKeyValue('lastName', _lastNameController.text));
    _dobController
        .addListener(() => saveUserInfoKeyValue('DOB', _dobController.text));
    _phoneNumberController.addListener(() {
      String enteredNumber = _phoneNumberController.text;
      String countryCode = '+91'; // Replace with your desired country code

      // Check if the country code is already present
      if (!enteredNumber.startsWith(countryCode)) {
        phoneNumberWithCountryCode = '$countryCode$enteredNumber';
      } else {
        phoneNumberWithCountryCode = enteredNumber;
      }

      saveUserInfoKeyValue('phone_number', phoneNumberWithCountryCode);
    });
    _whatsappNumberController.addListener(() {
      String enteredNumber = _whatsappNumberController.text;
      String countryCode = '+91'; // Replace with your desired country code

      // Check if the country code is already present
      if (!enteredNumber.startsWith(countryCode)) {
        whatsappNumberWithCountryCode = '$countryCode$enteredNumber';
      } else {
        whatsappNumberWithCountryCode = enteredNumber;
      }

      saveUserInfoKeyValue('whatsappContact', whatsappNumberWithCountryCode);
    });
    _secondaryNumberController.addListener(() {
      String enteredNumber = _secondaryNumberController.text;
      String countryCode = '+91'; // Replace with your desired country code

      // Check if the country code is already present
      if (!enteredNumber.startsWith(countryCode)) {
        alternateNumberWithCountryCode = '$countryCode$enteredNumber';
      } else {
        alternateNumberWithCountryCode = enteredNumber;
      }

      saveUserInfoKeyValue('alternateNumber', alternateNumberWithCountryCode);
    });
    _accountNumberController.addListener(() =>
        saveUserInfoKeyValue('accountNumber', _accountNumberController.text));
    _ifscCodeController.addListener(
        () => saveUserInfoKeyValue('IFSCCode', _ifscCodeController.text));
    _bankBranchCodeController.addListener(() =>
        saveUserInfoKeyValue('branchCode', _bankBranchCodeController.text));
    _addressController.addListener(
        () => saveUserInfoKeyValue('address', _addressController.text));
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoStr = prefs.getString('user_info');
    if (userInfoStr != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoStr);
      setState(() {
        _firstNameController.text = userInfo['firstName'] ?? '';
        _middleNameController.text = userInfo['middleName'] ?? '';
        _lastNameController.text = userInfo['lastName'] ?? '';
        _dobController.text = userInfo['DOB'] ?? '';
        _phoneNumberController.text = userInfo['phone_number'] ?? '';
        _whatsappNumberController.text = userInfo['whatsappContact'] ?? '';
        _secondaryNumberController.text = userInfo['alternateNumber'] ?? '';
        _accountNumberController.text = userInfo['accountNumber'] ?? '';
        _ifscCodeController.text = userInfo['IFSCCode'] ?? '';
        _bankBranchCodeController.text = userInfo['branchCode'] ?? '';
        _addressController.text = userInfo['address'] ?? '';
        _emailController.text = userInfo['email'] ?? '';
      });
    }
  }

  void _handleGenderChange(String? value) {
    setState(() {
      _selectedGender = value!;
      saveUserInfoKeyValue('gender', _selectedGender.toString());
    });
  }

  void _handleSameAsMobileChange(bool? value) {
    if (value != null) {
      setState(() {
        _sameAsMobileNumber = value;
        if (_sameAsMobileNumber) {
          _whatsappNumberController.text = _phoneNumberController.text;
        } else {
          _whatsappNumberController.text = '';
        }
      });
    }
  }

  String generateOTP() {
    Random random = Random();
    int otp = random.nextInt(10000);
    return otp.toString().padLeft(4, '0');
  }

  @override
  void dispose() {
    // Dispose controllers when not needed
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _phoneNumberController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankBranchCodeController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd')
            .format(picked); // Adjust the date format as needed
      });
    }
  }

  Future<void> saveUserInfoKeyValue(String key, dynamic value) async {
    Map<String, dynamic> newData = {key: value};
    await saveUserInfo(newData);
  }

  Future<void> saveUserInfo(Map<String, dynamic> newData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoStr = prefs.getString('user_info');
    Map<String, dynamic> userInfo =
        userInfoStr != null ? jsonDecode(userInfoStr) : {};
    userInfo.addAll(newData);
    await prefs.setString('user_info', jsonEncode(userInfo));
  }

  void _register() async {
    if (_isRegistering) return;

    setState(() {
      showError = true;
      _isRegistering = true;
    });

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        phoneNumberWithCountryCode.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _ifscCodeController.text.isEmpty ||
        _bankBranchCodeController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _emailController.text.isEmpty) {
      Toast.showToast(
          message: "Please fill all required fields", isError: true);
      setState(() {
        _isRegistering = false;
      });
      return;
    }
    // if (!_emailController.text.trim().endsWith('@gmail.com')) {
    //   setState(() {
    //     _isRegistering = false;
    //   });
    //   return;
    // }

    // _phoneNumberController.text = '+91${_phoneNumberController.text}'; // Add country code

    var userData = {
      'firstName': _firstNameController.text,
      'middleName': _middleNameController.text,
      'lastName': _lastNameController.text,
      'DOB': _dobController.text,
      'phone_number': phoneNumberWithCountryCode,
      'whatsappContact': whatsappNumberWithCountryCode,
      'alternateNumber': alternateNumberWithCountryCode,
      'gender': _selectedGender,
      'accountNumber': _accountNumberController.text,
      'IFSCCode': _ifscCodeController.text,
      'branchCode': _bankBranchCodeController.text,
      'address': _addressController.text,
      'email': _emailController.text
    };

    await saveUserInfo(userData);

    Navigator.of(context)
        .push(transitionToNextScreen(const DocumentationScreen()));

    setState(() {
      _isRegistering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Register with us!',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: colorGreen,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: mediumSmall,
                          color: colorGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: 70,
                    color: const Color(0xFFB8B8B8),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: const Color(0xFFB8B8B8),
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontSize: mediumSmall,
                          color: Color(0xFFB8B8B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: 70,
                    color: const Color(0xFFB8B8B8),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: const Color(0xFFB8B8B8),
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontSize: mediumSmall,
                          color: Color(0xFFB8B8B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Personal\nInformation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: small,
                      color: colorGreen,
                    ),
                  ),
                  Text(
                    'Documentation',
                    style: TextStyle(
                      fontSize: small,
                      color: Color(0xFFB8B8B8),
                    ),
                  ),
                  Text(
                    'Work\nPreferances',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: small,
                      color: Color(0xFFB8B8B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Personal Information',
                style: TextStyle(
                  color: colorGreen,
                  fontSize: mediumLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GreyContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                      label: '*FIRST NAME',
                      controller: _firstNameController,
                    ),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _firstNameController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                    CustomTextField(
                      label: 'MIDDLE NAME',
                      controller: _middleNameController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                      label: '*LAST NAME',
                      controller: _lastNameController,
                    ),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _lastNameController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                    const Text(
                      '*Select Gender',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Male',
                              groupValue: _selectedGender,
                              onChanged: _handleGenderChange,
                              activeColor: colorGreen,
                            ),
                            const Text(
                              'Male',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Female',
                              groupValue: _selectedGender,
                              onChanged: _handleGenderChange,
                              activeColor: colorGreen,
                            ),
                            const Text(
                              'Female',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Not to Say',
                              groupValue: _selectedGender,
                              onChanged: _handleGenderChange,
                              activeColor: colorGreen,
                            ),
                            const Text(
                              'Rather not say',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                      label: '*DATE OF BIRTH',
                      controller: _dobController,
                      icon: IconButton(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(
                          Icons.calendar_month,
                          color: colorGreen,
                        ),
                      ),
                    ),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _dobController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                    CustomPhoneField(
                      controller: _phoneNumberController,
                    ),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _phoneNumberController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                    CustomPhoneField(
                      label: '*WHATSAPP NUMBER',
                      controller: _whatsappNumberController,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _sameAsMobileNumber,
                          onChanged: _handleSameAsMobileChange,
                          activeColor: colorGreen,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _sameAsMobileNumber = !_sameAsMobileNumber;
                              if (_sameAsMobileNumber) {
                                _whatsappNumberController.text =
                                    _phoneNumberController.text;
                              } else {
                                _whatsappNumberController.text = '';
                              }
                            });
                          },
                          child: const Text(
                            'Same as mobile number',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomPhoneField(
                      label: 'SECONDARY NUMBER (OPTIONAL)',
                      controller: _secondaryNumberController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                        label: '*Email', controller: _emailController),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _emailController.text.isEmpty && showError
                              ? '  *required field'
                              // : !_emailController.text
                              //             .trim()
                              //             .endsWith('@gmail.com') &&
                              //         showError
                              //     ? 'Invalid Email'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                    CustomTextField(
                        label: '*ADDRESS', controller: _addressController),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _addressController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'BANK DETAILS',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GreyContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                      label: '*ACCOUNT NUMBER',
                      controller: _accountNumberController,
                    ),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _accountNumberController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                    CustomTextField(
                      label: '*IFSC CODE',
                      controller: _ifscCodeController,
                    ),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _ifscCodeController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                    CustomTextField(
                      label: '*BANK BRANCH CODE',
                      controller: _bankBranchCodeController,
                    ),
                    SizedBox(
                        height: 20,
                        child: Text(
                          _bankBranchCodeController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const InfoContainer(
                message:
                    'Your earnings will be transferred to this bank account every week.',
              ),
              const SizedBox(
                height: 30,
              ),
              FullWidthGreenButton(
                label: 'NEXT',
                onPressed: _register,
                isLoading: _isRegistering,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

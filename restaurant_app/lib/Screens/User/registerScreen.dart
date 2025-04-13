import 'dart:convert';
// Add this import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Add this import
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Screens/User/ownerDetailsScreen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/User/registrationTimeline.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/input_fields/textInputField.dart';
import 'package:restaurant_app/Widgets/noteWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this import

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}
class _RegistrationScreenState extends State<RegistrationScreen> {
  String nukkadCity = '';
  String nukkadAddress = '';
  String nukkadPincode = '';
  String nukkadLandmark = '';
  String nukkadContact='';

  final nukkadCityController = TextEditingController();
  final nukkadAddressController = TextEditingController();
  final nukkadPincodeController = TextEditingController();
  final nukkadLandmarkController = TextEditingController();

  String accountNumber = '';
  String ifscCode = '';
  String bankBranchCode = '';

  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final bankBranchCodeController = TextEditingController();

  String password = '';
  String confirmPassword = '';

  GoogleMapController? mapController; // Nullable type

  final nukkadContactController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final LocalController _getSavedData = LocalController();
  Map<String, dynamic>? userInfo;
  Position? _currentPosition; // Nullable type
  double getLatitude = 0.0;
  double getLongitude = 0.0;
  bool _isLoading = false;
  bool _isProcessing = false;
  bool showError=false;
  LatLng _userCurrentPosition = LatLng(60.0, 60.0);

  @override
  void initState() {
    super.initState();
    getUserData();
    _getCurrentLocation();
    getContactNumber(); // Retrieve the saved contact number
  }

  Future<void> loadEnv() async {
    await dotenv.load(fileName: ".env");
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        getLatitude = _currentPosition?.latitude ?? 0.0;
        getLongitude = _currentPosition?.longitude ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getUserData() async {
    try {
      Map<String, dynamic>? getData = await _getSavedData.getUserInfo();
      if (getData != null) {
        setState(() {
          userInfo = getData;
          accountNumberController.text = userInfo!['bankAccountNo'] ?? '';
          ifscCodeController.text = userInfo!['bankIFSCcode'] ?? '';
          bankBranchCodeController.text = userInfo!['bankBranch'] ?? '';
          confirmPasswordController.text = 'NOPassword';
          nukkadContactController.text = userInfo!['phoneNumber'] ?? '';
          passwordController.text = 'NOPassword';
          nukkadAddressController.text = userInfo!['nukkadAddress'] ?? '';
          nukkadCityController.text = userInfo!['city'] ?? '';
          nukkadPincodeController.text = userInfo!['pincode'] ?? '';
          nukkadLandmarkController.text = userInfo!['landmark'] ?? '';

          // Update the state variables
          nukkadCity = userInfo!['city'] ?? '';
          nukkadAddress = userInfo!['nukkadAddress'] ?? '';
          nukkadPincode = userInfo!['pincode'] ?? '';
          nukkadLandmark = userInfo!['landmark'] ?? '';
          accountNumber = userInfo!['bankAccountNo'] ?? '';
          ifscCode = userInfo!['bankIFSCcode'] ?? '';
          bankBranchCode = userInfo!['bankBranch'] ?? '';
          nukkadContact = userInfo!['phoneNumber'] ?? '';
          password = 'NoPasswords'; // Set default password
          confirmPassword = 'NoPasswords'; // Set default confirm password
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> routenext() async {
    if (_isProcessing) return; // Prevent multiple clicks
    setState(() {
      _isProcessing = true;// Set flag to true
      showError=true;
    });
    print(nukkadContact);

    if (nukkadCity.isNotEmpty &&
        nukkadAddress.isNotEmpty &&
        nukkadPincode.isNotEmpty &&
        nukkadLandmark.isNotEmpty &&
        accountNumber.isNotEmpty &&
        ifscCode.isNotEmpty &&
        bankBranchCode.isNotEmpty) {
      if (userInfo != null) {
        userInfo!['nukkadAddress'] = nukkadAddress;
        userInfo!['latitude'] = getLatitude;
        userInfo!['longitude'] = getLongitude;
        userInfo!['bankAccountNo'] = accountNumber;
        userInfo!['bankIFSCcode'] = ifscCode;
        userInfo!['bankBranch'] = bankBranchCode;
        userInfo!['phoneNumber'] = nukkadContact;
        userInfo!['password'] = 'nopassword';
        userInfo!['pincode'] = nukkadPincode;
        userInfo!['city'] = nukkadCity;
        userInfo!['landmark'] = nukkadLandmark;
        await saveUserInfo(userInfo!);

        Navigator.of(context).push(
         transitionToNextScreen( OwnerDetailsScreen()),
        );
      }
    } else {
      setState(() {
        _isProcessing = false; // Reset flag on failure
      });
      
    }
  }

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_info', jsonEncode(userInfo));
      print(prefs.getString('user_info'));
    } catch (e) {
      print('Error saving user info: $e');
    }
  }

  Future<void> getContactNumber() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedContactNumber = prefs.getString('contact_number');
      if (savedContactNumber != null) {
        print('Saved contact number: $savedContactNumber');
        setState(() {
          nukkadContact = savedContactNumber;
          nukkadContactController.text = savedContactNumber;
        });
      } else {
        print('No contact number found in SharedPreferences');
      }
    } catch (e) {
      print('Error retrieving contact number: $e');
    }
  }

  void _getUsersCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable them.
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle appropriately.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle appropriately.
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userCurrentPosition = LatLng(position.latitude, position.longitude);
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _userCurrentPosition,
            zoom: 12.0,
          ),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    'Register with us!',
                    style: h2TextStyle.copyWith(fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              const RegistrationTimeline(pageIndex: 0),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 3.h, bottom: 2.h),
                  child: Text(
                    'Nukkad Information'.toUpperCase(),
                    style: h4TextStyle.copyWith(color: primaryColor,fontSize: 15.sp),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: textGrey2, width: 0.2.w)),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h,bottom: 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textInputField(
                              ' *City'.toUpperCase(), nukkadCityController,
                              (String input) {
                            setState(() {
                              nukkadCity = input;
                            });
                          }),  
                        SizedBox(
                        height: 3.h,
                        child: Text(
                          nukkadCityController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red),
                        ),
                                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                          child: textInputField(
                              '*Address'.toUpperCase(), nukkadAddressController,
                              (String input) {
                            setState(() {
                              nukkadAddress = input;
                            });
                          }),
                        ),
                         SizedBox(
                        height: 3.h,
                        child: Text(
                          nukkadAddressController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red),
                        ),
                                          ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            autofocus: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            keyboardType: TextInputType.number,
                            controller: nukkadPincodeController,
                            onChanged: (value) {
                              setState(() {
                                nukkadPincode = value;
                              });
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide:
                                    BorderSide(color: textGrey2, width: 0.1.h),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                                borderSide:
                                    BorderSide(color: textGrey2, width: 0.1.h),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 2.h),
                              labelText: '*PINCODE'.toUpperCase(),
                              labelStyle: body4TextStyle.copyWith(color: textGrey2),
                            ),
                          ),
                           SizedBox(
                        height: 3.h,
                        child: Text(
                          nukkadPincodeController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red),
                        ),
                                          ),
                        ],
                      ),
                    ),
                   
                       Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textInputField(
                              '*Landmark'.toUpperCase(), nukkadLandmarkController,
                              (String input) {
                            setState(() {
                              nukkadLandmark = input;
                            });
                          }),
                           SizedBox(
                        height: 3.h,
                        child: Text(
                          nukkadLandmarkController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red),
                        ),
                                          ),
                        ],
                      ),
                    
                    Padding(
                      padding: EdgeInsets.only(top: 1.h, bottom: 2.h),
                      child: noteWidget(
                          'Please enter the same address as in the documentation.'),
                    ),
                  ],
                ),
              ),
              // Align(
              //   alignment: Alignment.center,
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              //     child: Text(
              //       'Select your location on map'.toUpperCase(),
              //       style: titleTextStyle,
              //     ),
              //   ),
              // ),
              // MapTest(),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                  child: Text(
                    'BANK DETAILS'.toUpperCase(),
                    style: titleTextStyle,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: textGrey2, width: 0.2.w),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h,),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textInputFieldNumber(
                              '*Account Number'.toUpperCase(),
                              accountNumberController, (String input) {
                            setState(() {
                              accountNumber = input;
                            });
                          }),
                           SizedBox(
                        height: 3.h,
                        child: Text(
                          accountNumberController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red),
                        ),
                                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textInputField(
                              '*IFSC Code'.toUpperCase(), ifscCodeController,
                              (String input) {
                            setState(() {
                              ifscCode = input;
                            });
                          }),
                           SizedBox(
                        height: 3.h,
                        child: Text(
                          ifscCodeController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red),
                        ),
                                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textInputField('*Bank Branch Code'.toUpperCase(),
                              bankBranchCodeController, (String input) {
                            setState(() {
                              bankBranchCode = input;
                            });
                          }),
                           SizedBox(
                        height: 3.h,
                        child: Text(
                          bankBranchCodeController.text.isEmpty && showError
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red),
                        ),
                                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height : 30),
              mainButton(
                  'Next',
                  textWhite,
                  routenext,
                  isLoading:
                      _isProcessing, // Pass the flag to control button state
                ),
                  SizedBox(height : 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget textInputFieldNumber(String labelText,
      TextEditingController controller, Function(String) onInputChanged) {
    controller.addListener(() {
      onInputChanged(controller.text);
    });
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(7),
      child: TextField(
        controller: controller,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(18),
        ],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: textGrey2, width: 0.1.h),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: textGrey2, width: 0.1.h),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          labelText: labelText.toUpperCase(),
          labelStyle: body4TextStyle.copyWith(color: textGrey2),
        ),
        onChanged: (value) {
          onInputChanged(value);
        },
      ),
    );
  }
}

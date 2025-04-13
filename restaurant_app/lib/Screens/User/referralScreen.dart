import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Controller/uni_service.dart';
import 'package:restaurant_app/Screens/User/registerScreen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/input_fields/textInputField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  int? _selectedOption;
  late LocalController _getSavedData;
  String executiveId = '';
  String executiveName = '';
  Map<String, dynamic> userInfo = {}; // Initialize as an empty map
  final executiveIdController = TextEditingController();
  final executiveNameController = TextEditingController();
  final db = FirebaseFirestore.instance.collection('public').doc('nukkad');
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getSavedData = LocalController();
    getUserData();
    loadData();
  }

  Future<void> getUserData() async {
    try {
      Map<String, dynamic>? getData = await _getSavedData.getUserInfo();
      setState(() {
        userInfo = getData!;
        // isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  void loadData() async {
    if (UniService.executiveId == null) {
      final temp = (await db.get()).get('code');
      if (temp != null) {
        executiveIdController.text = temp;
        db.update({'code': null});
        _selectedOption = 0;
      }
    } else {
      executiveIdController.text = UniService.executiveId!;
      _selectedOption = 0;
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void routeRegistration() {
    if (_selectedOption != null) {
      // setState(() {
      //   isLoading = true;
      // });

      if (_selectedOption == 0) {
        userInfo = {
          'referred': {
            'referredby': true,
            'reference': executiveIdController.text,
          }
        };
      } else if (_selectedOption == 1) {
        userInfo = {
          'referred': {'referred': true, 'reference': 'A Friend'}
        };
      } else {
        userInfo = {
          'referred': {'referred': false, 'reference': 'Self Registration'}
        };
      }

      saveUserInfo(userInfo);

      // setState(() {
      //   isLoading = false;
      // });

      Navigator.push(
        context,
        transitionToNextScreen(const RegistrationScreen()),
      );
    } else {
      // Show a snackbar or alert indicating the user must select an option
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: colorFailure,
          content: Text("Please select a field"),
        ),
      );
    }
  }

  Future<void> saveUserInfo(Map<String, dynamic> newData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoStr = prefs.getString('user_info');
    Map<String, dynamic> userInfo =
        userInfoStr != null ? jsonDecode(userInfoStr) : {};
    userInfo.addAll(newData);
    await prefs.setString('user_info', jsonEncode(userInfo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/otpbg.png',
            fit: BoxFit.cover,
            height: MediaQuery.sizeOf(context).height,
          ),
        ),
        SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(top: 8.h, left: 5.w, right: 5.w),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Who recommended nukkad foods to you?'
                                .toUpperCase(),
                            style: body3TextStyle,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Column(
                          children: [
                            buildRadioButton(0, "Nukkad Foods Executive"),
                            Visibility(
                              visible: _selectedOption == 0,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 2.h,
                                        right: 5.w,
                                        left: 5.w,
                                        bottom: 2.h),
                                    child: textInputField(
                                        'Executive ID', executiveIdController,
                                        (String id) {
                                      setState(() {
                                        executiveId = id;
                                      });
                                    }),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 2.h,
                                        right: 5.w,
                                        left: 5.w,
                                        bottom: 2.h),
                                    child: textInputField('Executive Name',
                                        executiveNameController, (String name) {
                                      setState(() {
                                        executiveName = name;
                                      });
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            buildRadioButton(1, "A Friend"),
                            buildRadioButton(2, "Self Registration"),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding:
                            EdgeInsets.only(right: 5.w, left: 5.w, top: 2.h),
                        child: mainButton(
                            'NEXT', textWhite, () => routeRegistration(),
                            isLoading: isLoading),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
          ),
        ),
      ]),
    );
  }

  Widget buildRadioButton(int value, String title) {
    return RadioListTile<int>(
      value: value,
      groupValue: _selectedOption,
      onChanged: (newValue) {
        setState(() {
          _selectedOption = newValue;
        });
      },
      toggleable: true,
      title: Text(
        title,
        style: body3TextStyle.copyWith(fontWeight: FontWeight.w600),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: primaryColor,
    );
  }
}

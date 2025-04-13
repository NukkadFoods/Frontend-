import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/screens/authentication_screens/register_with_us_screen.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/uni_service.dart';
import 'package:driver_app/widgets/common/custom_text_field.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:driver_app/controller/profile/profile_controller.dart';

import '../../utils/font-styles.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  int _selectedRadio = 2;

  LocalController _getSavedData = LocalController();
  late Map<String, dynamic> userInfo;
  bool isLoading = true;
  // Controllers for the text fields in the first option
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final db = FirebaseFirestore.instance
      .collection('public')
      .doc('nukkad-delivery-partner');

  void _handleRadioValueChanged(int? value) {
    setState(() {
      _selectedRadio = value!;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getReferralInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void getReferralInfo() async {
    if (UniService.executiveId == null) {
      final temp = (await db.get()).get('code');
      if (temp != null) {
        // refercodecontroller.text = temp;
        _idController.text = temp;
        _selectedRadio = 0;
        db.update({'code': null});
      }
    } else {
      _idController.text = UniService.executiveId!;
      _selectedRadio = 0;
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
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

  routeRegistration() {
    if (_selectedRadio == 0 &&
        (_nameController.text.isEmpty || _idController.text.isEmpty)) {
      return;
    }
    if (_selectedRadio == 0) {
      userInfo = {
        'isReferred': {
          'referred': true,
          'reference': _idController.text,
        }
      };
      // userInfo['referred'] = true;
      // userInfo['referredd'] = 'Delivery Partner Executive';
      // userInfo['executiveId'] = _idController;
      // userInfo['executiveName'] = _nameController;
    } else if (_selectedRadio == 1) {
      userInfo = {
        'isReferred': {'referred': true, 'reference': "friend"}
      };
      // userInfo['referred'] = true;
      // userInfo['referredd'] = 'A Friend';
    } else {
      userInfo = {
        'isReferred': {'referred': false, 'reference': 'Self Registration'}
      };
      // userInfo['referred'] = true;
      // userInfo['referredd'] = 'Self Registration';
    }
    saveUserInfo(userInfo);
    Navigator.of(context).push(transitionToNextScreen(RegisterWithUsScreen()));
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    'WHO RECOMMENDED NUKKAD FOODS TO YOU?',
                    style: TextStyle(
                      fontSize: medium,
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    title: Text(
                      'Nukkad foods Executive',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Radio<int>(
                      value: 0,
                      groupValue: _selectedRadio,
                      onChanged: _handleRadioValueChanged,
                      activeColor: colorGreen,
                    ),
                  ),
                  if (_selectedRadio == 0)
                    Column(
                      children: [
                        CustomTextField(
                          label: 'EXECUTIVE ID',
                          controller: _idController,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        CustomTextField(
                          label: 'EXECUTIVE NAME',
                          controller: _nameController,
                        ),
                      ],
                    ),
                  ListTile(
                    title: Text(
                      'A friend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Radio<int>(
                      value: 1,
                      groupValue: _selectedRadio,
                      onChanged: _handleRadioValueChanged,
                      activeColor: colorGreen,
                    ),
                  ),
                  // if (_selectedRadio == 1)
                  //   CustomTextField(
                  //     label: 'Referral Code',
                  //     controller: _referralCode,
                  //   ),
                  ListTile(
                    title: Text(
                      'Self Registration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Radio<int>(
                      value: 2,
                      groupValue: _selectedRadio,
                      onChanged: _handleRadioValueChanged,
                      activeColor: colorGreen,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FullWidthGreenButton(
                    label: 'NEXT',
                    // onPressed: () {
                    //   Navigator.of(context)
                    //       .push(transitionToNextScreen(RegisterWithUsScreen()));
                    // })
                    onPressed: routeRegistration,
                  )
                ],
              ),
      ),
    );
  }
}

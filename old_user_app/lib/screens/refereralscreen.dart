import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/utils/uniservice.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/input_fields/textInputField.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  int? _selectedOption;
  String executiveId = '';
  String executiveName = '';
  String userInfo = ''; // Initialize as an empty map
  final executiveIdController = TextEditingController();
  final executiveNameController = TextEditingController();
  final refercodecontroller = TextEditingController();
  String? saveAs;
  String? currentAddress;
  bool isLoading = true;
  final db =
      FirebaseFirestore.instance.collection('public').doc('nukkad-foods');

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    if (UniService.referralCode == null && UniService.executiveId == null) {
      try {
        final temp = (await db.get()).get('code');
        if (temp != null) {
          refercodecontroller.text = temp;
          executiveIdController.text = temp;
          _selectedOption = 1;
          db.update({'code': null});
        }
      } catch (e) {
        print(e);
      }
    } else if (UniService.referralCode != null) {
      refercodecontroller.text = UniService.referralCode!;
      _selectedOption = 1;
    } else if (UniService.executiveId != null) {
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
      if (_selectedOption == 0) {
        userInfo = json.encode({
          'referredby': executiveNameController.text,
          'reference': executiveIdController.text,
          // 'executiveName': executiveNameController.text,
        });
      } else if (_selectedOption == 1) {
        userInfo = json.encode({
          // 'referredby': true,

          'reference': refercodecontroller.text.isNotEmpty
              ? refercodecontroller.text
              : 'nocode',
          'referredby': 'A Friend',
        });
      } else {
        userInfo = json.encode({
          'reference': "none",
          'referredby': 'Self Registration',
        });
      }

      saveUserInfo(userInfo);

      // userSignUp();

      // Navigator.push(
      //   context,
      //   transitionToNextScreen(const LocationSetupScreen(isAdd: false)),
      // );
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

  Future<void> saveUserInfo(String newData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('refer', newData); // No need to jsonEncode twice
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            height: MediaQuery.sizeOf(context).height,
          ),
        ),
        SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
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
                                    }, context),
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
                                    }, context),
                                  ),
                                ],
                              ),
                            ),
                            buildRadioButton(1, "A Friend"),
                            Visibility(
                              visible: _selectedOption == 1,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 2.h,
                                    right: 5.w,
                                    left: 5.w,
                                    bottom: 2.h),
                                child: textInputField('Enter Referral code',
                                    refercodecontroller, // Correct controller used here
                                    (String code) {
                                  setState(() {
                                    // Set the referral code here if needed
                                  });
                                }, context),
                              ),
                            ),
                            buildRadioButton(2, "Self Registration"),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding:
                            EdgeInsets.only(right: 5.w, left: 5.w, top: 2.h),
                        child: mainButton(
                          'NEXT',
                          textWhite,
                          () => routeRegistration(),
                        ),
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
        style: body3TextStyle.copyWith(
            fontWeight: FontWeight.w600, fontSize: 12.sp),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: primaryColor,
    );
  }
}

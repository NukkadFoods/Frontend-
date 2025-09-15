import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Screens/User/ownerDetailsScreen.dart';
import 'package:restaurant_app/Screens/User/setOrderingScreen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/User/registrationTimeline.dart';
import 'package:restaurant_app/Widgets/customs/User/uploadWidget.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/input_fields/textInputField.dart';
import 'package:restaurant_app/Widgets/noteWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';


class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({super.key});

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}
class _DocumentationScreenState extends State<DocumentationScreen> {
  String gstinNumber = '';
  String fssaiNumber = '';
  String fssaiExpiryDate = '';
  final gstController = TextEditingController();
  final fssaiController = TextEditingController();
  final fssaiDateController = TextEditingController();

  bool _isGSTUploaded = false;
  bool _isFSSAIUploaded = false;
 bool _showerror=false;

  String? imageFssaiPath;
  String? imageGstPath;

  LocalController _getSavedData = LocalController();
  late Map<String, dynamic> userInfo;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', jsonEncode(userInfo));
  }

  Future<void> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('user_info');
      if (userDataString != null) {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        setState(() {
          userInfo = userData;
          gstController.text = userData['gstNumber'];
          fssaiController.text = userData['fssaiCertificateNumber'];
          fssaiDateController.text = userData['fssaiExpiryDate'];
          imageGstPath = userData['gstCertificate'];
          imageFssaiPath = userData['fssaiCertificate'];
          _isGSTUploaded = imageGstPath != null;
          _isFSSAIUploaded = imageFssaiPath != null;
        });
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  void _deleteGSTCertificate() {
    setState(() {
      _isGSTUploaded = false;
      imageGstPath = null;
    });
  }

  void _deleteFSSAI() {
    setState(() {
      _isFSSAIUploaded = false;
      imageFssaiPath = null;
    });
  }

  routeOrdering() {
    setState(() {
      _showerror=true;
    });
    if (gstinNumber.isNotEmpty &&
        fssaiNumber.isNotEmpty &&
        fssaiExpiryDate.isNotEmpty) {
      userInfo['gstNumber'] = gstinNumber;
      userInfo['gstCertificate'] = imageGstPath;
      userInfo['fssaiCertificateNumber'] = fssaiNumber;
      userInfo['fssaiExpiryDate'] = fssaiExpiryDate;
      userInfo['fssaiCertificate'] = imageFssaiPath;

      saveUserInfo(userInfo);
      Navigator.push(context,
        transitionToNextScreen( const SetOrderingScreen()));
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     backgroundColor: colorFailure,
      //     content: Text("GST, FSSAI  is required")));
    }
  }

  @override
  void dispose() {
    gstController.dispose();
    fssaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OwnerDetailsScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20.sp,
          ),
        ),
        title: Text('Documentation', style: h4TextStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const RegistrationTimeline(pageIndex: 2),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                child: Text('GST Details'.toUpperCase(), style: titleTextStyle),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 3.w, right: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: textGrey2, width: 0.2.w),
              ),
              child: Column(
                children: [
                  textInputField('*GSTIN Number', gstController, (String input) {
                    gstinNumber = input;
                  }),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       SizedBox(
                              height: 2.h,
                              child: Text(
                              gstController.text.isEmpty && _showerror
                                  ? '  *required field'
                                  : '',
                              style: TextStyle(color: Colors.red)),
                            ),
                     ],
                   ),
                  SizedBox(height: 1.h),
                  Text('Upload GST Certificate'),
                  SizedBox(height: 1.h),
                  UploadImageWidget(
                    context: context,
                    type: 'GST',
                    imageUrl: imageGstPath,
                    onFilePicked: (String? imageUrl) {
                      setState(() {
                        imageGstPath = imageUrl;
                        _isGSTUploaded = imageUrl != null;
                      });
                    },
                    onDelete: _deleteGSTCertificate,
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                child: Text('FSSAI Details'.toUpperCase(), style: titleTextStyle),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 3.w, right: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: textGrey2, width: 0.2.w),
              ),
              child: Column(
                children: [
                  textInputField('*FSSAI Number', fssaiController, (String input) {
                    fssaiNumber = input;
                  }),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       SizedBox(
                              height: 2.h,
                              child: Text(
                              fssaiController.text.isEmpty && _showerror
                                  ? '  *required field'
                                  : '',
                              style: TextStyle(color: Colors.red)),
                            ),
                     ],
                   ),
                  SizedBox(height: 1.h),
                  textInputField('*FSSAI Expiry Date', fssaiDateController, (String input) {
                    fssaiExpiryDate = input;
                  }),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       SizedBox(
                              height: 2.h,
                              child: Text(
                              fssaiDateController.text.isEmpty && _showerror
                                  ? '  *required field'
                                  : '',
                              style: TextStyle(color: Colors.red)),
                            ),
                     ],
                   ),
                  SizedBox(height: 1.h),
                  Text('Upload FSSAI Certificate'),
                    SizedBox(height: 1.h),
                  UploadImageWidget(
                    context: context,
                    type: 'FSSAI',
                    imageUrl: imageFssaiPath,
                    onFilePicked: (String? imageUrl) {
                      setState(() {
                        imageFssaiPath = imageUrl;
                        _isFSSAIUploaded = imageUrl != null;
                      });
                    },
                    onDelete: _deleteFSSAI,
                  ),
                    Padding(
                    padding: EdgeInsets.all(1.h),
                    child: noteWidget(
                        'As per government guidelines, you can not operate food business without FSSAI License.'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
           
          mainButton('Proceed', textWhite, routeOrdering),
              SizedBox(height: 3.h),
          ],

        ),
      ),
    );
  }
}
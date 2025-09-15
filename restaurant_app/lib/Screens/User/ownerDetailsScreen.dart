import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Screens/User/registerScreen.dart';
import 'package:restaurant_app/Screens/map/map_screen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/User/registrationTimeline.dart';
import 'package:restaurant_app/Widgets/customs/User/uploadWidget.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/input_fields/numberInputField.dart';
import 'package:restaurant_app/Widgets/input_fields/phoneField.dart';
import 'package:restaurant_app/Widgets/input_fields/textInputField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';

import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'package:path/path.dart' as path;

class OwnerDetailsScreen extends StatefulWidget {
  const OwnerDetailsScreen({super.key});

  @override
  State<OwnerDetailsScreen> createState() => _OwnerDetailsScreenState();
}
class _OwnerDetailsScreenState extends State<OwnerDetailsScreen> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  Uint8List? _signatureImageBytes;
  File? _image;
  String? _downloadURLOwnerImage;
  String? _downloadURLSignature;
  String? imagebannerpath;
  String? imageSignaturePath;
  String? imagePanPath;
  String? imageAadharFrontPath;
  String? imageAadharBackPath;
  String ownerName = '';
  String ownerEmail = '';
  String ownerPhone = '';
  String currentAddress = '';
  String permanentAddress = '';
  String nukkadPhoneNumber = '';
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerEmailController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController currentAddressController = TextEditingController();
  final TextEditingController permanentAddressController = TextEditingController();
  String aadharNumber = '';
  String panNumber = '';
  final aadharNumberController = TextEditingController();
  final panNumberController = TextEditingController();
   final FirebaseAuth _auth = FirebaseAuth.instance;
  int? _selectedOption;
  bool whatsappConfirmation = false;
  bool isSignatureUploaded = false;
  bool isPanUploaded = false;
  bool isAadharBackUploaded = false;
  bool isAadharUploadeFront = false;
  bool useSameRestaurantPhone = false;
  bool useSameAddress = false;
  bool _showerror=false;
  String? aadharFrontUrl;
  String? aadharBackUrl;
  String? panCardUrl;
  String? userImageUrl;
  String? signatureUrl;
  LocalController _getSavedData = LocalController();
  late Map<String, dynamic> userInfo;

  @override
  void initState() {
    super.initState();
      login();
    _checkPermission();
    getUserData();
    getContactNumber();
    login();
  }
  
  void login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firebase = prefs.getString('firebase');
    print(firebase);
    if (firebase != null) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: '$firebase@gmail.com', password: firebase);
        print('logged in to Firebase');
      } catch (e) {
        print('Login error in firebase');
      }
      // _user = userCredential.user;
    }
  }

  void _handleFilePicked(String type, String? imageUrl) {
    setState(() {
      switch (type) {
        case 'Aadhar Front':
          aadharFrontUrl = imageUrl;
          break;
        case 'Aadhar Back':
          aadharBackUrl = imageUrl;
          break;
        case 'PAN Card':
          panCardUrl = imageUrl;
          break;
        case 'User Image':
          userImageUrl = imageUrl;
          break;
        case 'Signature':
          signatureUrl = imageUrl;
          break;
      }
    });
  }

  void _handleDelete(String type) {
    setState(() {
      switch (type) {
        case 'Aadhar Front':
          aadharFrontUrl = null;
          break;
        case 'Aadhar Back':
          aadharBackUrl = null;
          break;
        case 'PAN Card':
          panCardUrl = null;
          break;
        case 'User Image':
          userImageUrl = null;
          break;
        case 'Signature':
          signatureUrl = null;
          break;
      }
    });
  }



  Future<void> _checkPermission() async {
    PermissionStatus status = await Permission.camera.status;
    print('Camera Permission Status: $status');

    if (status != PermissionStatus.granted) {
      await _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    try {
      PermissionStatus status = await Permission.camera.request();
      if (status == PermissionStatus.granted) {
        print('Camera Permission Granted');
      } else {
        print('Camera Permission Denied');
      }
    } catch (e) {
      print('Error requesting camera permission: $e');
    }
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
          nukkadPhoneNumber = userInfo['phoneNumber'] ?? '';
          ownerNameController.text = userInfo['ownerName'] ?? '';
          ownerPhoneController.text = userInfo['ownerContactNumber'] ?? '';
          currentAddressController.text = userInfo['currentAddress'] ?? '';
          permanentAddressController.text = userInfo['permananetAddress'] ?? '';
          ownerEmailController.text = userInfo['ownerEmail'] ?? '';
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getContactNumber() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedContactNumber = prefs.getString('contact_number');
      if (savedContactNumber != null) {
        print('Saved contact number: $savedContactNumber');
        setState(() {
          nukkadPhoneNumber = savedContactNumber;
          ownerPhoneController.text = savedContactNumber;
          userInfo['phoneNumber'] = savedContactNumber;
        });
      } else {
        print('No contact number found in SharedPreferences');
      }
    } catch (e) {
      print('Error retrieving contact number: $e');
    }
  }

  routeDocumentation() {
    setState(() {
      _showerror=true;
    });
   
    if (aadharNumber.isNotEmpty &&
        panNumber.isNotEmpty &&
        ownerEmail.isNotEmpty &&
        ownerName.isNotEmpty &&
        ownerPhoneController.text.isNotEmpty) {
      userInfo['ownerPhoto'] = _downloadURLOwnerImage;
      userInfo['ownerName'] = ownerName;
      userInfo['ownerEmail'] = ownerEmail;
      userInfo['ownerContactNumber'] = ownerPhoneController.text;
      userInfo['currentAddress'] = currentAddress;
      userInfo['permananetAddress'] = permanentAddress;
      userInfo['kycAadhar'] = aadharFrontUrl;
      userInfo['kycPan'] = panCardUrl;
      userInfo['signature'] = _downloadURLSignature;
      userInfo['adharnumber']= aadharNumberController.text;
      userInfo['pannumber']=panNumber;


      saveUserInfo(userInfo);
      Navigator.push(
        context,
      transitionToNextScreen( const MapsScreen()),
      );
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     backgroundColor: colorFailure,
      //     content: Text("All fields are required")));
    }
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
                builder: (context) => const RegistrationScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20.sp,
          ),
        ),
        title: Text('Owner\'s Photo', style: h4TextStyle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const RegistrationTimeline(pageIndex: 1),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
                child:
                    Text('Owner Details'.toUpperCase(), style: titleTextStyle),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Stack(children: [
                CircleAvatar(
                  backgroundColor: Colors.amber[800],
                  radius: 90,
                  child: CircleAvatar(
                    radius: 80, 
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider<Object>?
                        : AssetImage('assets/images/owner.png'),
                  ),
                ),
                // _image == null
                //     ? Image.asset('assets/images/owner.png')
                //     : Image.file(_image!),
                // Image.asset('assets/images/owner.png'),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: ((builder) => bottomSheet()),
                      );
                    },
                    child: Container(
                        width: 45, // Adjust the width and height as needed
                        height: 45,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.red
                            // .red, // Adjust the color as needed
                            ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          // size: 15,
                          color: Colors.white,
                        )),
                  ),
                ),
              ]),
            ),
            Container(
              margin: EdgeInsets.only(top: 3.h, left: 3.w, right: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: textGrey2, width: 0.2.w),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textInputField(
                            '*Owner\'s Full Name', ownerNameController,
                            (String input) {
                          setState(() {
                            ownerName = input;
                          });
                        }),
                         SizedBox(
                          height: 2.h,
                          child: Text(
                          ownerNameController.text.isEmpty && _showerror
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textInputField(
                            'Owner\'s Email Address', ownerEmailController,
                            (String input) {
                          setState(() {
                            ownerEmail = input;
                          });
                        }),
                        SizedBox(
                          height: 2.h,
                          child: Text(
                          ownerEmailController.text.isEmpty && _showerror
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  ),
                  // Align(
                  //     alignment: Alignment.topLeft,
                  //     child:
                  //         buildRadioButton(0, 'Same as restaurant mobile no.')),
                  Align(
                    alignment: Alignment.topLeft,
                    child: CheckboxListTile(
                      value: useSameRestaurantPhone,
                      onChanged: (bool? value) {
                        setState(() {
                          useSameRestaurantPhone = value ?? false;
                          if (useSameRestaurantPhone) {
                            // Trim the country code (assuming it is the first 3 characters)
                            String trimmedPhone = nukkadPhoneNumber.length > 3
                                ? nukkadPhoneNumber.substring(3)
                                : nukkadPhoneNumber;
                            ownerPhoneController.text = trimmedPhone;
                            ownerPhone = trimmedPhone;
                          } else {
                            ownerPhoneController.clear();
                            ownerPhone = '';
                          }
                        });
                      },
                      title: Text('Same as restaurant mobile no.',style: body4TextStyle,),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: colorSuccess,
                    ),
                  ),
                  PhoneField(
                    controller: ownerPhoneController,
                    onPhoneNumberChanged: (String number) {
                      setState(() {
                        ownerPhone = number;
                      });
                    },
                    
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: CheckboxListTile(
                      value: whatsappConfirmation,
                      onChanged: (value) {
                        setState(() {
                          whatsappConfirmation = value ?? false;
                          print('Whatsapp confirmation: $whatsappConfirmation');
                        });
                      },
                      title: Text('Yes, this is my whatsapp no.',
                          style: body4TextStyle),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: colorSuccess,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      textInputField('*Current Address', currentAddressController,
                          (String input) {
                        setState(() {
                          // currentAddressController.text = input;
                          currentAddress = input;
                        });
                      }),
                       SizedBox(
                          height: 2.h,
                          child: Text(
                          currentAddressController.text.isEmpty && _showerror
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red)),
                        )
                    ],
                  ),
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: SizedBox(
                  //       width: 80.w,
                  //       child: buildRadioButton(1, 'Same as current address.')),
                  // ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: CheckboxListTile(
                      value: useSameAddress,
                      onChanged: (bool? value) {
                        setState(() {
                          useSameAddress = value ?? false;
                          if (useSameAddress) {
                            permanentAddressController.text =
                                currentAddressController.text;
                            permanentAddress = currentAddressController.text;
                          } else {
                            permanentAddressController.clear();
                            permanentAddress = '';
                          }
                        });
                      },
                      title: Text('Same as current address.'),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: colorSuccess,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      textInputField(
                          'Permanent Address', permanentAddressController,
                          (String input) {
                        setState(() {
                          permanentAddress = input;
                        });
                      }),
                      SizedBox(
                          height: 2.h,
                          child: Text(
                          permanentAddressController.text.isEmpty && _showerror
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red)),
                        )
                    ],
                  ),
                  SizedBox(height: 3.h),
                  
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                child: Text('KYC Details'.toUpperCase(), style: titleTextStyle),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 1.h, 0, 0.5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        numberInputField(
                            '*Aadhaar Number', aadharNumberController,
                            (String input) {
                          setState(() {
                            aadharNumber = input;
                          });
                        }),
                         SizedBox(
                          height: 2.h,
                          child: Text(
                          aadharNumberController.text.isEmpty && _showerror
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Spacer(),
                      verified(),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 1.h, 0, 0.5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textInputField('*PAN Number', panNumberController,
                            (String input) {
                          setState(() {
                            panNumber = input;
                          });
                        }),
                         SizedBox(
                          height: 2.h,
                          child: Text(
                          panNumberController.text.isEmpty && _showerror
                              ? '  *required field'
                              : '',
                          style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Spacer(),
                      verified(),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 3.h, left: 3.w, right: 3.w),
              padding: EdgeInsets.only(left: 3.w, bottom: 5.h, right: 3.w),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
  children: [
    Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upload Aadhar Front'.toUpperCase(),
              style: titleTextStyle,
            ),
            SizedBox(width: 1.w),
            SvgPicture.asset('assets/icons/upload_icon.svg'),
          ],
        ),
      ),
    ),
      UploadImageWidget(
            context: context,
            type: 'Aadhar Front',
            imageUrl: aadharFrontUrl,
            onFilePicked: (imageUrl) => _handleFilePicked('Aadhar Front', imageUrl),
            onDelete: () => _handleDelete('Aadhar Front'),
              )],
),

            ),
            Container(
              margin: EdgeInsets.only(top: 3.h, left: 3.w, right: 3.w),
              padding: EdgeInsets.only(left: 3.w, bottom: 5.h, right: 3.w),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
  children: [
    Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upload Aadhar Back'.toUpperCase(),
              style: titleTextStyle,
            ),
            SizedBox(width: 1.w),
            SvgPicture.asset('assets/icons/upload_icon.svg'),
          ],
        ),
      ),
    ),   UploadImageWidget(
            context: context,
            type: 'Aadhar Back',
            imageUrl: aadharBackUrl,
            onFilePicked: (imageUrl) => _handleFilePicked('Aadhar Back', imageUrl),
            onDelete: () => _handleDelete('Aadhar Back'),
          ),
  ],
),

            ),
            Container(
              margin: EdgeInsets.only(top: 3.h, left: 3.w, right: 3.w),
              padding: EdgeInsets.only(left: 3.w, bottom: 5.h, right: 3.w),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child:Column(
  children: [
    Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upload PAN'.toUpperCase(),
              style: titleTextStyle,
            ),
            SizedBox(width: 1.w),
            SvgPicture.asset('assets/icons/upload_icon.svg'),
          ],
        ),
      ),
    ),
       UploadImageWidget(
            context: context,
            type: 'PAN Card',
            imageUrl: panCardUrl,
            onFilePicked: (imageUrl) => _handleFilePicked('PAN Card', imageUrl),
            onDelete: () => _handleDelete('PAN Card'),
          ),
  ],
),

            ),
            Text(
              'Signature hear'.toUpperCase(),
              style: titleTextStyle,
            ),
            Column(
                children: [
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                          child: SfSignaturePad(
                              key: signatureGlobalKey,
                              backgroundColor: Colors.white,
                              strokeColor: Colors.black,
                              minimumStrokeWidth: 1.0,
                              maximumStrokeWidth: 4.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)))),
                  SizedBox(height: 10),
                  Row(children: <Widget>[
                    TextButton(
                      child: Text('Upload Signature '),
                      onPressed: _handleSaveButtonPressed,
                    ),
                    TextButton(
                      child: Text('Clear'),
                      onPressed: _handleClearButtonPressed,
                    )
                  ], mainAxisAlignment: MainAxisAlignment.spaceEvenly)
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center),
            SizedBox(height: 2.h),
            // Show the captured signature image
            _showSignatureImage(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
              child: mainButton('Save Details', textWhite, routeDocumentation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showSignatureImage() {
    if (_signatureImageBytes != null) {
      return Image.memory(_signatureImageBytes!);
    } else {
      return Text('No signature captured');
    }
  }

  void _handleSignaturePicked(bool isPicked, String? filePath) {
    setState(() {
      isSignatureUploaded = isPicked;
      imageSignaturePath = filePath;
    });
  }

  void _handlePanPicked(bool isPicked, String? filePath) {
    setState(() {
      isPanUploaded = isPicked;
      imagePanPath = filePath != null ? path.basename(filePath) : null;
    });
    print(filePath);
    print(imagePanPath);
  }

  void _handleAadharFrontPicked(bool isPicked, String? filePath) {
    setState(() {
      isAadharUploadeFront = isPicked;
      imageAadharFrontPath = filePath != null ? path.basename(filePath) : null;
    });
    print(filePath);
    print(imageAadharFrontPath);
  }

  void _handleAadharBackPicked(bool isPicked, String? filePath) {
    setState(() {
      isAadharBackUploaded = isPicked;
      imageAadharBackPath = filePath != null ? path.basename(filePath) : null;
    });
    print(filePath);
    print(imageAadharBackPath);
  }

  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState!.clear();
  }
 Future<void> _handleSaveButtonPressed() async {
    if (signatureGlobalKey.currentState != null) {
      // Retrieve the drawn signature as a data blob
      final data = await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
      final byteData = await data.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      setState(() {
        _signatureImageBytes = bytes;
      });

      // Upload image to Firebase Storage
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().toIso8601String()}.png');
        await ref.putData(bytes);

        final url = await ref.getDownloadURL();

        setState(() {
          _downloadURLSignature = url;
        });

        print('Download URL: $_downloadURLSignature');
      } catch (e) {
        print('Error uploading signature: $e');
      }
    }
  }
  // void _handleSaveButtonPressed() async {
  //   final data =
  //       await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
  //   final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
  //   await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (BuildContext context) {
  //         return Scaffold(
  //           appBar: AppBar(),
  //           body: Center(
  //             child: Container(
  //               color: Colors.grey[300],
  //               child: Image.memory(bytes!.buffer.asUint8List()),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget buildRadioButton(int value, String title) {
    return RadioListTile<int>(
      value: value,
      groupValue: _selectedOption,
      onChanged: (newValue) {
        setState(() {
          // ownerPhoneController.text = nukkadPhoneNumber;
          _selectedOption = newValue;
          if (newValue != null && title == 'Same as current address.') {
            permanentAddress = currentAddressController.text;
            permanentAddressController.text = currentAddressController.text;
          } else {
            permanentAddressController.clear();
          }
          if (newValue == 0) {
            ownerPhoneController.text = nukkadPhoneNumber;
            ownerPhone = nukkadPhoneNumber;
          } else {
            ownerPhoneController.clear();
            ownerPhone = '';
          }
        });
      },
      toggleable: true,
      title: Text(
        title,
        style: body4TextStyle.copyWith(
            fontSize: 11.sp, fontWeight: FontWeight.w400),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: primaryColor,
    );
  }

  Widget verified() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/verified_icon.svg',
            color: colorSuccess,
          ),
          Text(
            'Verified',
            style: body5TextStyle.copyWith(
              color: colorSuccess,
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Choose Profile photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.camera),
                  onPressed: () {
                    // pickImage();
                    pickImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  onPressed: () {
                    // pickImage();
                    pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                  label: const Text("Gallery"),
                ),
              ])
        ],
      ),
    );
  }

  Future pickImage(ImageSource source) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imagebannerpath = _image!.path;
      });

      // Upload image to Firebase Storage
      try {
        // AuthProvider authProvider =
        //     Provider.of<AuthProvider>(context, listen: false);

        // await authProvider.signInWithEmailAndPassword();
        final ref = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now().toString()}');
        await ref.putFile(_image!);
        final url = await ref.getDownloadURL();

        setState(() {
          _downloadURLOwnerImage = url;
        });

        print(_downloadURLOwnerImage);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
}
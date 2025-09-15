import 'dart:io';
import 'dart:convert';

import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/screens/authentication_screens/work_preference_screen.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/grey_container.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/font-styles.dart';

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({super.key});

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> {
  int? _selectedIdentityProof;
  File? _image;
  String? _downloadURLIdentityProof;
  String? _downloadURLPanCard;
  String? _downloadURLAddressProof;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool uploadingIdProof = false;
  bool uploadingPANCard = false;
  bool uploadingAddressProof = false;
  bool showError = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firebase = prefs.getString('firebase');
    print(firebase);
    if (firebase != null) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: '$firebase@gmail.com', password: firebase);
        print('logged in to Firebase');
      } catch (e) {
        print('Login error in firebase');
      }
      // _user = userCredential.user;
    }
  }

  void _handleIdentityProofChange(int? value) {
    setState(() {
      _selectedIdentityProof = value;
    });
  }

  Future<void> _checkPermission() async {
    PermissionStatus status = await Permission.camera.status;
    print('Camera Permission Status: $status');

    if (status != PermissionStatus.granted) {
      // If the camera permission is not granted, request it
      await _requestPermission();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _downloadURLAddressProof = prefs.getString('drivingLicensePic');
    _downloadURLIdentityProof = prefs.getString('idProofPic');
    _downloadURLPanCard = prefs.getString('pancardPic');
  }

  Future<void> _requestPermission() async {
    try {
      PermissionStatus status = await Permission.camera.request();
      if (status == PermissionStatus.granted) {
        // Permission granted, proceed with camera usage
        print('Camera Permission Granted');
      } else {
        // Permission denied, handle accordingly
        print('Camera Permission Denied');
      }
    } catch (e) {
      // Handle any exceptions that occur during the permission request
      print('Error requesting camera permission: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
        ),
        title: const Text(
          'Documentation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorGreen,
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: 70,
                    color: colorGreen,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
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
                        '2',
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
                      color: colorGreen,
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
                'IDENTITY PROOF',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GreyContainer(
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: medium,
                          ),
                        ),
                        Text('Choose one as a proof of identity'),
                        SizedBox(),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Radio<int>(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: 0,
                              groupValue: _selectedIdentityProof,
                              onChanged: _handleIdentityProofChange,
                              activeColor: colorGreen,
                            ),
                            const Text(
                              'Aadhar Card',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // const SizedBox(width: 20),
                        Row(
                          children: [
                            Radio<int>(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: 1,
                              groupValue: _selectedIdentityProof,
                              onChanged: _handleIdentityProofChange,
                              activeColor: colorGreen,
                            ),
                            const Text(
                              'Voter ID Card',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      textAlign: TextAlign.center,
                      'Front side photo of your Aadhar card with your clear name and photo',
                      style: TextStyle(
                        color: Color(
                          0xFFB8B8B8,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedIdentityProof == null) {
                          Toast.showToast(
                              message: "Select a ID proof first",
                              isError: true);
                          return;
                        }
                        if (!uploadingIdProof) {
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) =>
                                bottomSheet(DocumentType.identityProof)),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: colorGreen),
                          ),
                        ),
                      ),
                      child: uploadingIdProof
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                                Text('  Uploading Image...')
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _downloadURLIdentityProof != null
                                      ? Icons.done
                                      : Icons.camera_alt,
                                  color: colorGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _downloadURLIdentityProof != null
                                      ? "Picture Uploaded"
                                      : 'Upload Photo',
                                  style: const TextStyle(color: colorGreen),
                                ),
                                _downloadURLIdentityProof != null
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _downloadURLIdentityProof = null;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ))
                                    : const SizedBox.shrink()
                              ],
                            ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                    height: 30,
                    child: Text(
                      _downloadURLIdentityProof == null && showError
                          ? '  *required upload'
                          : '',
                      style: TextStyle(color: Colors.red),
                    )),
              ),
              const Text(
                'PAN CARD',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GreyContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: medium,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * .75),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Front side photo of your Pan card with your clear name and photo',
                            style: TextStyle(
                              color: Color(
                                0xFFB8B8B8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: ((builder) =>
                              bottomSheet(DocumentType.panCard)),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: colorGreen),
                          ),
                        ),
                      ),
                      child: uploadingPANCard
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                                Text('  Uploading Image...')
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _downloadURLPanCard != null
                                      ? Icons.done
                                      : Icons.camera_alt,
                                  color: colorGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _downloadURLPanCard != null
                                      ? 'Picture Uploaded'
                                      : 'Upload Photo',
                                  style: const TextStyle(color: colorGreen),
                                ),
                                _downloadURLPanCard != null
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _downloadURLPanCard = null;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ))
                                    : const SizedBox.shrink()
                              ],
                            ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                    height: 30,
                    child: Text(
                      _downloadURLPanCard == null && showError
                          ? '  *required upload'
                          : '',
                      style: TextStyle(color: Colors.red),
                    )),
              ),
              const Text(
                'DRIVING LICENSE',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GreyContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '3.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: medium,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * .75),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Front side photo of your Driving license card with your clear name and photo',
                            style: TextStyle(
                              color: Color(
                                0xFFB8B8B8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: ((builder) =>
                              bottomSheet(DocumentType.addressProof)),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: colorGreen),
                          ),
                        ),
                      ),
                      child: uploadingAddressProof
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                                Text('  Uploading Image...')
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _downloadURLAddressProof != null
                                      ? Icons.done
                                      : Icons.camera_alt,
                                  color: colorGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _downloadURLAddressProof != null
                                      ? 'Picture Uploaded'
                                      : 'Upload Photo',
                                  style: const TextStyle(color: colorGreen),
                                ),
                                _downloadURLAddressProof != null
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _downloadURLAddressProof = null;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ))
                                    : const SizedBox.shrink()
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                    height: 30,
                    child: Text(
                      _downloadURLAddressProof == null && showError
                          ? '  *required upload'
                          : '',
                      style: TextStyle(color: Colors.red),
                    )),
              ),
              FullWidthGreenButton(
                  label: 'NEXT',
                  onPressed: () {
                    setState(() {
                      showError = true;
                    });
                    if (_downloadURLAddressProof != null &&
                        _downloadURLIdentityProof != null &&
                        _downloadURLPanCard != null) {
                      Navigator.of(context).push(
                          transitionToNextScreen(const WorkPreferenceScreen()));
                    } else {
                      Toast.showToast(
                          message: "Please fill all required fields",
                          isError: true);
                    }
                  }),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSheet(DocumentType type) {
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
            "Choose Image",
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
                    pickImage(ImageSource.camera, type);
                    Navigator.pop(context);
                  },
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  onPressed: () {
                    // pickImage();
                    pickImage(ImageSource.gallery, type);
                    Navigator.pop(context);
                  },
                  label: const Text("Gallery"),
                ),
              ])
        ],
      ),
    );
  }

  Future pickImage(ImageSource source, DocumentType type) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      // setState(() {
      _image = File(pickedFile.path);
      //   imagebannerpath = _image!.path;
      // });

      // Upload image to Firebase Storage
      try {
        // AuthProvider authProvider =
        //     Provider.of<AuthProvider>(context, listen: false);

        // await authProvider.signInWithEmailAndPassword();
        String fileName = "";
        setState(() {
          switch (type) {
            case DocumentType.addressProof:
              {
                uploadingAddressProof = true;
                fileName = "ad";
              }
              break;
            case DocumentType.panCard:
              {
                uploadingPANCard = true;
                fileName = "p";
              }
              break;
            case DocumentType.identityProof:
              {
                uploadingIdProof = true;
                fileName = "id";
              }
              break;
            }
        });
        final ref = FirebaseStorage.instance.ref().child(
            'images/verificationDocs/$fileName${_auth.currentUser!.email!.split("@")[0]}');
        await ref.putFile(_image!);
        final url = await ref.getDownloadURL();
        print(url);
        switch (type) {
          case DocumentType.addressProof:
            {
              uploadingAddressProof = false;
              setState(() {
                _downloadURLAddressProof = url;
              });
              saveUserInfoKeyValue('drivingLicensePic', url);
            }
            break;
          case DocumentType.panCard:
            {
              uploadingPANCard = false;
              setState(() {
                _downloadURLPanCard = url;
              });
              saveUserInfoKeyValue('pancardPic', url);
            }
            break;
          case DocumentType.identityProof:
            {
              uploadingIdProof = false;
              setState(() {
                _downloadURLIdentityProof = url;
              });
              saveUserInfoKeyValue("idProofPic", url);
            }
            break;
          }

        // setState(() {
        //   _downloadURLOwnerImage = url;
        // });

        // print(_downloadURLOwnerImage);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
}

enum DocumentType { identityProof, panCard, addressProof }

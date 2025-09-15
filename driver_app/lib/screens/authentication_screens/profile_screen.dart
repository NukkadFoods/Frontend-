import 'dart:convert';

import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/screens/authentication_screens/referral_screen.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/common/custom_text_field.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:driver_app/widgets/common/info_container.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../../utils/font-styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _profilenameController = TextEditingController();
  bool uploading = false;
  String? firebase;

  File? _image;
  String? _downloadURLProfileImage;

  late Map<String, dynamic> userInfo;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getUserData();
    _loadUserInfo();
    _addListeners();
    login();
  }

  void login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firebase = prefs.getString('firebase');
    print(firebase);
    if (firebase != null) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: '$firebase@gmail.com', password: firebase!);
        print('logged in to Firebase');
      } catch (e) {
        print('Login error in firebase');
      }
      // _user = userCredential.user;
    }
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoStr = prefs.getString('user_info');
    if (userInfoStr != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoStr);
      setState(() {
        _profilenameController.text = userInfo['name'] ?? '';
      });
    }
  }

  void _addListeners() {
    _profilenameController.addListener(
        () => saveUserInfoKeyValue('name', _profilenameController.text));
  }

  @override
  void dispose() {
    super.dispose();
    _profilenameController.dispose();
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

  Future<void> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('user_info');
      if (userDataString != null) {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        setState(() {
          userInfo = userData;
          _profilenameController.text = userInfo['name'] ?? '';
        });
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  void routeReferral() async {
    if (_profilenameController.text.isNotEmpty) {
      // var addData = {
      //   'name': _profilenameController.text,
      // };
      await saveUserInfoKeyValue('name', _profilenameController.text);
      print(_downloadURLProfileImage);
      await saveUserInfoKeyValue('profilePic', _downloadURLProfileImage);
      Navigator.of(context).push(transitionToNextScreen(ReferralScreen()));
    } else {
      Toast.showToast(message: "Name is required", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  'LET’S GET STARTED!',
                  style: TextStyle(
                    fontSize: medium,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'YOUR PROFILE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: large,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Choose how people will see your stall',
                        style: TextStyle(
                          color: colorGray,
                          fontSize: mediumSmall,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => bottomSheet(),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 4,
                                  color: colorGreen,
                                ),
                                borderRadius: BorderRadius.circular(60)),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  _image != null ? FileImage(_image!) : null,
                              child: _image == null
                                  ? Icon(Icons.add_a_photo)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        label: 'YOUR NAME',
                        controller: _profilenameController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InfoContainer(
                          message:
                              'This is the name and picture that customers will see on the app.')
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FullWidthGreenButton(
                    label: 'GET STARTED', onPressed: routeReferral),
              ],
            ),
          ),
        ),
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

  Future pickImage(
    ImageSource source,
  ) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        //   imagebannerpath = _image!.path;
      });

      // Upload image to Firebase Storage
      try {
        // AuthProvider authProvider =
        //     Provider.of<AuthProvider>(context, listen: false);

        // await authProvider.signInWithEmailAndPassword();

        uploading = true;
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images/$firebase');
        await ref.putFile(_image!);
        final url = await ref.getDownloadURL();
        print(url);
        uploading = false;
        _downloadURLProfileImage = url;
        await saveUserInfoKeyValue('profilePic', _downloadURLProfileImage);
        print('Profile Picture Uploaded and Saved');

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

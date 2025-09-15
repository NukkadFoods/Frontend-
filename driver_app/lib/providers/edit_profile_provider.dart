import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/common/custom_phone_field.dart';

// shared pref string for user data ='deliveryBoyData'

class EditProfileProvider extends ChangeNotifier {
  EditProfileProvider(var this.userInfo) {
    log(userInfo.toString());
    nameController = TextEditingController(text: userInfo['name'] ?? '');
    dobController = TextEditingController(
        text: userInfo['DOB'] != null
            ? userInfo['DOB'].toString().split('T')[0]
            : '');
    emailController = TextEditingController(text: userInfo['email'] ?? '');
    addressController = TextEditingController(text: userInfo['address'] ?? '');
    accountController = TextEditingController(
        text: userInfo['bankDetails'] != null
            ? userInfo['bankDetails']['accountNumber'] ?? ''
            : '');
    ifscController = TextEditingController(
        text: userInfo['bankDetails'] != null
            ? userInfo['bankDetails']['IFSCCode'] ?? ''
            : '');
    branchController = TextEditingController(
        text: userInfo['bankDetails'] != null
            ? userInfo['bankDetails']['branchCode'] ?? ''
            : '');
    phoneNoController = CustomTextController(text: userInfo['contact'] ?? '');
    dobSuffix =
        userInfo['DOB'] != null ? userInfo['DOB'].toString().split('T')[1] : '';
    getId();
  }
  var userInfo;
  // final String baseurl = dotenv.env['BASE_URL']!;
  final String baseurl = AppStrings.baseURL;
  late final TextEditingController nameController;
  late final TextEditingController dobController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController accountController;
  late final TextEditingController ifscController;
  late final TextEditingController branchController;
  late final CustomTextController phoneNoController;
  bool enableUpdate = false;
  String uid = '';
  String dobSuffix = '';
  bool showErrors = false;

  void _updateFields() {
    nameController.text = userInfo['name'] ?? '';
    dobController.text =
        userInfo['DOB'] != null ? userInfo['DOB'].toString().split('T')[0] : '';
    emailController.text = userInfo['email'] ?? '';
    addressController.text = userInfo['address'] ?? '';
    accountController.text = userInfo['bankDetails']['accountNumber'] ?? '';
    ifscController.text = userInfo['bankDetails']['IFSCCode'] ?? '';
    branchController.text = userInfo['bankDetails']['branchCode'] ?? '';
    phoneNoController.text = userInfo['contact'] ?? '';
  }

  void getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid')!;
    if (uid.isNotEmpty) {
      enableUpdate = true;
      notifyListeners();
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // _selectedDate = picked;
      dobController.text = DateFormat('yyyy-MM-dd')
          .format(picked); // Adjust the date format as needed
    }
  }

  void updateDetails() async {
    showErrors = true;
    bool bankDetailsUpdated = false;
    if (nameController.text.isNotEmpty &&
            phoneNoController.text.isNotEmpty &&
            dobController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            accountController.text.isNotEmpty &&
            ifscController.text.isNotEmpty &&
            branchController.text.isNotEmpty
        // addressController.text.isNotEmpty
        ) {
      if (!enableUpdate) {
        return;
      }
      enableUpdate = false;
      notifyListeners();
      Map<String, dynamic> data = {
        'bankDetails': {
          'accountNumber': userInfo['bankDetails']['accountNumber'],
          'IFSCCode': userInfo['bankDetails']['IFSCCode'],
          'branchCode': userInfo['bankDetails']['branchCode'],
        }
      };
      if (nameController.text != userInfo['name']) {
        data['name'] = nameController.text;
      }
      if (phoneNoController.text != userInfo['contact']) {
        data['contact'] = phoneNoController.text;
      }
      if ('${dobController.text}T$dobSuffix' != userInfo['DOB']) {
        data['DOB'] = dobController.text;
      }
      if (emailController.text != userInfo['email']) {
        data['email'] = emailController.text;
      }
      // if (addressController.text != userInfo['name']) {
      //   data['name'] = nameController.text;
      // }
      if (accountController.text != userInfo['bankDetails']['accountNumber']) {
        bankDetailsUpdated = true;
        data['bankDetails']['accountNumber'] = accountController.text;
        data['bankDetails']['IFSCCode'] = ifscController.text;
        data['bankDetails']['branchCode'] = branchController.text;
      }
      if (ifscController.text != userInfo['bankDetails']['IFSCCode']) {
        bankDetailsUpdated = true;
        data['bankDetails']['accountNumber'] = accountController.text;
        data['bankDetails']['IFSCCode'] = ifscController.text;
        data['bankDetails']['branchCode'] = branchController.text;
      }
      if (branchController.text != userInfo['bankDetails']['branchCode']) {
        bankDetailsUpdated = true;
        data['bankDetails']['accountNumber'] = accountController.text;
        data['bankDetails']['IFSCCode'] = ifscController.text;
        data['bankDetails']['branchCode'] = branchController.text;
      }
      if (data.length > 1 || bankDetailsUpdated) {
        print(data);
        try {
          final response = await http.post(
              Uri.parse('$baseurl/auth/updateDeliveryBoyById'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'id': uid, 'updateData': data}));
          print(response.statusCode);
          if (response.statusCode == 200) {
            var temp = jsonDecode(response.body);
            userInfo = temp['deliveryBoy'];
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('deliveryBoyData', jsonEncode(userInfo));
            _updateFields();
            Toast.showToast(message: 'Profile Updated', isError: false);
          }
        } catch (e) {
          if (e is http.ClientException) {
            Toast.showToast(message: 'No Internet', isError: true);
          }
        }
      } else {
        Toast.showToast(message: "No changes");
      }
      enableUpdate = true;
    }
    notifyListeners();
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void editProfilePic(BuildContext context) async {
    XFile? profilePic =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (profilePic != null) {
      final cropped = await ImageCropper()
          .cropImage(sourcePath: profilePic.path, uiSettings: [
        AndroidUiSettings(
          hideBottomControls: true,
          toolbarTitle: 'Profile Picture',
          toolbarColor: colorBrightGreen,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Profile Picture',
          cropStyle: CropStyle.circle,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
      ]);
      if (cropped != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profile_images/${userInfo['_id']!}');
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => Dialog(
                  // insetPadding: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        Text('    Uploading...')
                      ],
                    ),
                  ),
                ));
        await ref.putFile(File(cropped.path));
        final url = await ref.getDownloadURL();
        try {
          final response =
              await http.post(Uri.parse('$baseurl/auth/updateDeliveryBoyById'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'id': uid,
                    'updateData': {"profilePic": url}
                  }));
          print(response.statusCode);
          if (response.statusCode == 200) {
            var temp = jsonDecode(response.body);
            userInfo = temp['deliveryBoy'];
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('deliveryBoyData', jsonEncode(userInfo));
            _updateFields();
            Toast.showToast(message: 'Profile Updated', isError: false);
          }
        } catch (e) {
          if (e is http.ClientException) {
            Toast.showToast(message: 'No Internet', isError: true);
          }
        }
        Navigator.of(context).pop();
      }
    }
    notifyListeners();
  }
}

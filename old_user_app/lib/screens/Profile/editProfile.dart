import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/navigation_extension.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/input_fields/phoneField.dart';
import 'package:user_app/widgets/input_fields/textInputField.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    super.key,
    required this.userModel,
  });
  final User userModel;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String userNumber = '';
  String? imageUrl;
  final userNamecontroller = TextEditingController();
  final userEmailcontroller = TextEditingController();
  final userNumbercontroller = TextEditingController();
  String userGender = "Male"; // Default gender value
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userNamecontroller.text = widget.userModel.username ?? "";
    userEmailcontroller.text = widget.userModel.email ?? "";
    userNumber = widget.userModel.contact ?? "";
    userNumbercontroller.text = userNumber.isNotEmpty
        ? userNumber.substring(userNumber.length - 10)
        : "";
    userGender = widget.userModel.gender ?? "Male";
    imageUrl = widget.userModel.userImage ?? '';
    // Set default gender from model
    // loadImageUrl();
  }

  Future<void> loadImageUrl() async {
    imageUrl = SharedPrefsUtil().getString(AppStrings.ownerImageUrl);
    setState(() {});
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1024, maxWidth: 1024);

    if (pickedFile != null) {
      // Automatically upload the image and update the profile
      await uploadImageToFirebase(File(pickedFile.path));
      if (imageUrl != null) {
        updateProfile(); // Update the profile with the new image URL after successful upload
      }
    } else {
      Fluttertoast.showToast(msg: 'No image selected');
    }
  }

  Future<void> uploadImageToFirebase(File imageFile) async {
    setState(() {
      isLoading = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/${widget.userModel.id}.png');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();

      // Save image URL in Shared Preferences
      await SharedPrefsUtil().setString(AppStrings.ownerImageUrl, imageUrl!);

      Fluttertoast.showToast(msg: 'Image uploaded successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to upload image: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    setState(() {
      isLoading = true;
    });

    var updateData = {
      "username": userNamecontroller.text,
      "contact": userNumber,
      "email": userEmailcontroller.text,
      "gender": userGender, // Add userGender to update data
      "userImage": imageUrl, // Add imageUrl to update data
    };
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";

    var updateResult = await UserController.updateUserById(
      id: userId,
      updateData: updateData,
      context: context,
    );

    updateResult.fold((String text) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: 'Something went wrong...!!',
          backgroundColor: textWhite,
          textColor: primaryColor);
    }, (UserModel updatedUser) {
      setState(() {
        isLoading = false;
        context.pop();
      });
      Fluttertoast.showToast(
          msg: 'Profile Updated Successfully...!!',
          backgroundColor: textWhite,
          textColor: colorSuccess);
    });
  }

  void routeHome() {
    if (userNumber.isNotEmpty &&
        userNumber.length > 10 &&
        userEmailcontroller.text.isNotEmpty &&
        userNamecontroller.text.isNotEmpty) {
      updateProfile();
    } else {
      Fluttertoast.showToast(
          msg: 'Please enter all details ...!!',
          backgroundColor: textWhite,
          textColor: primaryColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: h4TextStyle.copyWith(
                color: isdarkmode ? textGrey2 : textBlack)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Open image picker on tap
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 3)),
                      child: CircleAvatar(
                        radius: 8.h, // Adjust this radius based on your design
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/boyprofile.png',
                                    fit: BoxFit.cover,
                                    height: double.maxFinite,
                                    width: double.maxFinite,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/boyprofile.png',
                                  fit: BoxFit.cover,
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: IconButton(
                          onPressed: pickImage,
                          icon: SvgPicture.asset('assets/icons/Edit icon.svg')),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 5.h),
            textInputField(
                'Name', userNamecontroller, (String name) {}, context),
            SizedBox(height: 3.h),
            phoneField((number) {
              setState(() {
                userNumber = number;
              });
            }, context,
                controller: userNumbercontroller,
                initialPhoneNumber: userNumber,
                isReadOnly: true),
            SizedBox(height: 3.h),
            textInputField(
                'Email', userEmailcontroller, (String email) {}, context),
            SizedBox(height: 3.h),
            // Radio buttons for gender selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Radio<String>(
                  value: "male",
                  groupValue: userGender,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      userGender = value!;
                    });
                  },
                ),
                Text(
                  'male',
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: isdarkmode ? textGrey2 : textBlack),
                ),
                Radio<String>(
                  value: "female",
                  activeColor: primaryColor,
                  groupValue: userGender,
                  onChanged: (value) {
                    setState(() {
                      userGender = value!;
                    });
                  },
                ),
                Text(
                  'female',
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: isdarkmode ? textGrey2 : textBlack),
                ),
                Radio<String>(
                  value: "other",
                  groupValue: userGender,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      userGender = value!;
                    });
                  },
                ),
                Text(
                  'other',
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: isdarkmode ? textGrey2 : textBlack),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: colorFailure,
                    ),
                  )
                : mainButton('Update Profile', textWhite, routeHome),
          ],
        ),
      ),
    );
  }
}

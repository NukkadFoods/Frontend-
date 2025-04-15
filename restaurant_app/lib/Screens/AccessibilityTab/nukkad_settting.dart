import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';
import 'package:restaurant_app/Controller/wallet_controller.dart';
import 'package:restaurant_app/Screens/User/login_screen.dart';
import 'package:restaurant_app/Screens/map/map_screen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/loading_popup.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/registration/build_restaurant_operational_hours_widget.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:restaurant_app/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class NukkadSettingWidget extends StatefulWidget {
  const NukkadSettingWidget({super.key});

  @override
  State<NukkadSettingWidget> createState() => _NukkadSettingWidgetState();
}

class _NukkadSettingWidgetState extends State<NukkadSettingWidget> {
  final ownerNameController = TextEditingController();
  final nukkadAddressController = TextEditingController();
  final nukkadEmailController = TextEditingController();
  final nukkadphoneController = TextEditingController();
  String nukkadAddress = '';
  String nukkadEmail = '';
  String imageurl = '';
  File? _image;
  RestaurantModel? restaurantModel;
  LatLng? newLocation;
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  late List<bool> isOpen;
  late TimeOfDay openingTime;
  late TimeOfDay closingTime;
  late String selectedDate;
  // List<bool> isOpen = List.generate(7, (index) => false);
  // final ImagePicker imagebannerpath = ImagePicker();

  @override
  void initState() {
    super.initState();
    isOpen = List.filled(7, false);
    openingTime = TimeOfDay(hour: 9, minute: 30); // Set default opening time
    closingTime = TimeOfDay(hour: 21, minute: 30); // Set default closing tim
    fetchRestaurantModel();
  }

  Future<void> fetchRestaurantModel() async {
    String? restaurantJson =
        SharedPrefsUtil().getString(AppStrings.restaurantModel);
    if (restaurantJson != null && restaurantJson.isNotEmpty) {
      setState(() {
        restaurantModel = RestaurantModel.fromJson(json.decode(restaurantJson));
        ownerNameController.text = restaurantModel!.user!.nukkadName ?? "";
        nukkadAddressController.text =
            restaurantModel!.user!.nukkadAddress ?? "";
        nukkadEmailController.text = restaurantModel!.user!.ownerEmail ?? "";
        nukkadphoneController.text = restaurantModel!.user!.phoneNumber ?? "";
        imageurl = restaurantModel!.user!.restaurantImages != null
            ? restaurantModel!.user!.restaurantImages!.isNotEmpty
                ? restaurantModel!.user!.restaurantImages![0]
                : ""
            : '';
        print(restaurantModel!.user!.operationalHours);
        if (restaurantModel!.user!.operationalHours != null) {
          int index = 0;
          restaurantModel!.user!.operationalHours!.forEach((key, value) {
            index = daysOfWeek.indexOf(key);
            isOpen[index] = true;
          });
          final temp = restaurantModel!
              .user!.operationalHours!.entries.first.value
              .toString()
              .split("-");
          openingTime = TimeOfDay(
              hour: temp[0].endsWith('PM')
                  ? temp[0].startsWith('12')
                      ? int.tryParse(temp[0]
                          .split(String.fromCharCode(8239))[0]
                          .split(":")[0])!
                      : int.tryParse(temp[0]
                              .split(String.fromCharCode(8239))[0]
                              .split(":")[0])! +
                          12
                  : int.tryParse(temp[0]
                          .split(String.fromCharCode(8239))[0]
                          .split(":")[0])! %
                      12,
              minute: int.tryParse(
                  temp[0].split(String.fromCharCode(8239))[0].split(":")[1])!);
          closingTime = TimeOfDay(
              hour: temp[1].endsWith('PM')
                  ? int.tryParse(temp[1]
                          .split(String.fromCharCode(8239))[0]
                          .split(":")[0])! +
                      12
                  : int.tryParse(temp[1]
                          .split(String.fromCharCode(8239))[0]
                          .split(":")[0])! %
                      12,
              minute: int.tryParse(
                  temp[1].split(String.fromCharCode(8239))[0].split(":")[1])!);
        }
      });
    }
  }
//String.fromCharCode(8239)

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.jm().format(dateTime);
  }

  List<String> getSelectedDaysString(List<bool> selectedDays) {
    List<String> selectedDaysString = [];

    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        selectedDaysString.add(daysOfWeek[i]);
      }
    }

    // Remove the trailing comma and space
    // selectedDaysString = selectedDaysString.isNotEmpty
    //     ? selectedDaysString.substring(0, selectedDaysString.length - 2)
    //     : selectedDaysString;

    return selectedDaysString;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage('assets/images/otpbg.png'),
                    fit: BoxFit.cover))),
        // Image.asset(
        //     'assets/images/otpbg.png',
        //     fit: BoxFit.cover,
        //   ),
        Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Nukkad Info and settings', style: h4TextStyle),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 19.sp,
                  color: Colors.black,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100.w,
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.2.h, color: textGrey3),
                          color: bgColor,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: [
                            BoxShadow(
                              color: textGrey3.withOpacity(0.5), // Shadow color
                              spreadRadius: 2, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: Offset(
                                  2, 2), // Offset in the x and y directions
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Choose how people will see your stall',
                              style: body5TextStyle.copyWith(color: textGrey2),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Stack(children: [
                                CircleAvatar(
                                  radius: 80,
                                  backgroundImage: imageurl.isEmpty
                                      ? AssetImage(
                                              'assets/images/get_started.png')
                                          as ImageProvider
                                      : CachedNetworkImageProvider(imageurl),
                                ),
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
                                        width:
                                            45, // Adjust the width and height as needed
                                        height: 45,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red
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
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: textInputFields(
                                'Nukkads Name',
                                ownerNameController,
                                (String input) {
                                  // setState(() {
                                  //   ownerName = input;
                                  // });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 2.h),
                              width: 100.w,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.7.h),
                              decoration: BoxDecoration(
                                color: colorwarnig.withOpacity(0.3),
                                border: Border.all(
                                    width: 0.2.h, color: colorwarnig2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Note: ',
                                      style: body3TextStyle.copyWith(
                                        fontSize: 14,
                                        color: colorFailure,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'This is the name and picture that customers will see on the app.',
                                      style: body6TextStyle.copyWith(
                                        letterSpacing: 0.7,
                                        fontSize: 12,
                                        color: textBlack,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: textInputFields(
                          'ADDRESS',
                          nukkadAddressController, (String input) {},
                          // onTap: () {
                          //    Navigator.of(context)
                          //   .push(transitionToNextScreen( MapsScreen(restaurantModel: restaurantModel,)));
                          // },
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            final newData = await Navigator.of(context)
                                .push(transitionToNextScreen(MapsScreen(
                              restaurantModel: restaurantModel,
                            )));
                            if (newData != null) {
                              newLocation = newData;
                            }
                          },
                          child: Text("Change Nukkad's Location From Map",
                              style: TextStyle(
                                  decoration: TextDecoration.underline))),
                      SizedBox(
                        height: 2.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'nukkad Contact'.toUpperCase(),
                          style: titleTextStyle.copyWith(fontSize: 14.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: textInputFields(
                          'Phone Number',
                          nukkadphoneController,
                          (String input) {
                            setState(() {
                              nukkadEmail = input;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'restaurant operational hours'.toUpperCase(),
                          style: titleTextStyle.copyWith(fontSize: 14.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      RestaurantOperatingHoursWidget(
                        closingTime: closingTime,
                        openingTime: openingTime,
                        isOpen: isOpen,
                        onValuesChanged: (List<bool> newIsOpen,
                            TimeOfDay newOpeningTime,
                            TimeOfDay newClosingTime) {
                          setState(() {
                            isOpen = newIsOpen;
                            openingTime = newOpeningTime;
                            closingTime = newClosingTime;
                          });
                        },
                        daysOfWeek: daysOfWeek,
                        padding: EdgeInsets.symmetric(
                          vertical: 2.h,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 2.h,
                        ),
                        child: mainButton(
                            'save details'.toUpperCase(), textWhite, () async {
                          routerChat();
                          if (isOpen.contains(true)) {
                            Map<String, dynamic> updateData = {
                              'nukkadName': ownerNameController.text,
                              'nukkadAddress': nukkadAddressController.text,
                              'phoneNumber': "+91${nukkadphoneController.text}"
                            };
                            if (newLocation != null) {
                              updateData['latitude'] = newLocation!.latitude;
                              updateData['longitude'] = newLocation!.longitude;
                            }
                            bool update =
                                await LoginController.updateRestaurantDataByID(
                                    uid: SharedPrefsUtil()
                                        .getString(AppStrings.userId)!,
                                    data: updateData,
                                    context: context);
                            if (update) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  transitionToNextScreen(const HomeScreen()),
                                  (route) => route.isFirst);
                            }
                          }
                        }),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 2.h,
                          ),
                          child: SizedBox(
                            width: double.maxFinite,
                            height: 7.h,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: textWhite,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              onPressed: () async {
                                // await SharedPrefsUtil()
                                //     .remove(AppStrings.userId);
                                // Navigator.pushAndRemoveUntil(
                                //     context,
                                //     transitionToNextScreen(Login_Screen()),
                                //     (route) => false);
                                showConfirmationPage();
                              },
                              label: Text(
                                'DELETE ACCOUNT',
                                style: h5TextStyle.copyWith(color: textWhite),
                              ),
                              icon: Icon(Icons.delete_forever_outlined),
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 2.h,
                          ),
                          child: SizedBox(
                            width: double.maxFinite,
                            height: 7.h,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: textWhite,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  transaction.update(
                                      FirebaseFirestore.instance
                                          .collection('fcmTokens')
                                          .doc('user'),
                                      {
                                        SharedPrefsUtil()
                                                .getString(AppStrings.userId)!:
                                            FieldValue.delete()
                                      });
                                });
                                await SharedPrefsUtil()
                                    .remove(AppStrings.userId);
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    transitionToNextScreen(Login_Screen()),
                                    (route) => false);
                              },
                              label: Text(
                                'LOG OUT',
                                style: h5TextStyle.copyWith(color: textWhite),
                              ),
                              icon: Icon(Icons.login),
                            ),
                          )),
                      SizedBox(
                        height: 2.h,
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  void showConfirmationPage() async {
    bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: const Text(
                "Are you sure you want to delete your account? This action cannot be undone.",
                style: TextStyle(fontSize: 18),
              ),
              content: const Text('''
Deleting you account will :-
  1. Delete all your data from our server.
  2. Make you lose all your pending earnings and current wallet cash.
  3. Cancel all pending payout requests.

Do you want to proceed?'''),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: colorFailure),
                    child: const Text("Yes",
                        style: TextStyle(color: Colors.white))),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: colorSuccess),
                    child:
                        const Text("No", style: TextStyle(color: Colors.white)))
              ],
              actionsAlignment: MainAxisAlignment.spaceEvenly,
            ));
    if (confirm == true) {
      showLoadingPopup(context, 'Deleting Account...');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString(AppStrings.userId)!;
      // String baseUrl = dotenv.env['BASE_URL']!;
      String baseUrl = AppStrings.baseURL;
      final response = await http.post(
          Uri.parse("$baseUrl/auth/DeleteRestaurantById"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': uid}));
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['executed']) {
          await WalletController.deleteWallet();
          Toast.showToast(message: "Account Deleted Successfully!");
          prefs.clear();
          prefs.setBool('isFirstLaunch', false);
          FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(context,
              transitionToNextScreen(Login_Screen()), (route) => false);
        }
      }
    }
  }

  void routerChat() {
    if (isOpen.contains(true)) {
      Map<String, dynamic> operationalHours = Map.fromEntries(
          getSelectedDaysString(isOpen).map((key) => MapEntry(key,
              "${formatTimeOfDay(openingTime)} - ${formatTimeOfDay(closingTime)}")));
      LoginController.updateRestaurantByIDOperationalhours(
          uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
          operationalHours: operationalHours,
          context: context);
    } else {
      Toast.showToast(message: 'All Fields Are required ..!!', isError: true);
    }
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
      showLoadingPopup(context, "Updating Stall image");
      _image = File(pickedFile.path);

      // Upload the file to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
          'profile_images/${SharedPrefsUtil().getString(AppStrings.userId)}.png');

      UploadTask uploadTask = storageRef.putFile(_image!);

      // Get the download URL once the upload is complete
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      LoginController.updateRestaurantpicture(
          uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
          context: context,
          imageurl: downloadUrl);
      // Use the URL with NetworkImage
      fetchRestaurantModel();
      setState(() {
        imageurl = downloadUrl;
      });
    }
  }

  textInputFields(String s, TextEditingController ownerNameController,
      Null Function(String input) param2,
      {bool isReadOnly = false, GestureTapCallback? onTap}) {
    // controller.addListener(() {
    //   onInputChanged(controller.text);
    // });

    return Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(7),
      child: TextField(
        readOnly: isReadOnly,
        enabled: true,
        onTap: onTap,
        controller: ownerNameController,
        keyboardType: TextInputType.text,
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
          labelText: s,
          labelStyle: body4TextStyle.copyWith(color: textGrey2),
        ),
        // onChanged: (value) {
        //   onInputChanged(value);
        // },
      ),
    );
  }
}

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/controller/wallet_controller.dart';
import 'package:driver_app/screens/authentication_screens/signin_screen.dart';
import 'package:driver_app/screens/authentication_screens/work_preference_screen.dart';
import 'package:driver_app/screens/profile/about_screen.dart';
import 'package:driver_app/screens/profile/edit_profile_screen.dart';
import 'package:driver_app/screens/support_screens/chat_page.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/common/loading_popup.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/common/transition_to_next_screen.dart';
import 'package:http/http.dart' as http;

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  var deliveryBoyData;

  @override
  void initState() {
    super.initState();
    getDeliveryBoyData();
  }

  void getDeliveryBoyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? temp = prefs.getString('deliveryBoyData');
    if (temp != null) {
      deliveryBoyData = jsonDecode(temp);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(deliveryBoyData);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: veryLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 4,
                        color: colorGreen,
                      ),
                      shape: BoxShape.circle),
                  child: CircleAvatar(
                      radius: 60,
                      backgroundColor: colorGray,
                      foregroundImage: deliveryBoyData != null
                          ? deliveryBoyData['profilePic'] != null
                              // ? Image.network(deliveryBoyData['profilePic'])
                              ? CachedNetworkImageProvider(
                                  deliveryBoyData['profilePic'],
                                )
                              : deliveryBoyData['gender'] == 'Male'
                                  ? AssetImage(
                                      'assets/images/avatarm.png',
                                    )
                                  : AssetImage(
                                      'assets/images/avatarf.png',
                                    )
                          : AssetImage(
                              'assets/images/avatarm.png',
                            )),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  deliveryBoyData != null
                      ? deliveryBoyData['name'].toString()
                      : 'No data',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: large,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
                padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color(0xffF6F8FA)),
                child: Column(
                  children: [
                    CustomTile(
                      icon: const Icon(
                        Icons.person_outline,
                        color: colorBrightGreen,
                      ),
                      label: 'Edit Profile',
                      onTap: () async {
                        await Navigator.of(context)
                            .push(transitionToNextScreen(EditProfileScreen(
                          deliveryBoyData: deliveryBoyData,
                        )));
                        getDeliveryBoyData();
                      },
                    ),
                    CustomTile(
                      icon: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SvgPicture.asset(
                          'assets/svgs/work.svg',
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                              Colors.blue, BlendMode.srcATop),
                        ),
                      ),
                      label: 'Work Preference',
                      onTap: () async {
                        var updated = await Navigator.of(context)
                            .push(transitionToNextScreen(WorkPreferenceScreen(
                          isRegistering: false,
                        )));
                        if (updated is bool && updated == true) {
                          Toast.showToast(
                              message: 'Details Updated Successfully',
                              isError: false);
                        }
                      },
                    )
                  ],
                )),
            const SizedBox(
              height: 25,
            ),
            Container(
                padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color(0xffF6F8FA)),
                child: Column(
                  children: [
                    CustomTile(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Color(0xff369BFF),
                      ),
                      label: 'About',
                      onTap: () {
                        Navigator.of(context)
                            .push(transitionToNextScreen(const AboutScreen()));
                      },
                    ),
                    CustomTile(
                      icon: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SvgPicture.asset(
                          'assets/svgs/feedback.svg',
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                              Color(0xffB33DFB), BlendMode.srcATop),
                        ),
                      ),
                      // Icon(
                      //   Icons.favorite_border,
                      //   color: Color(0xffB33DFB),
                      // ),
                      label: 'Send Feedback',
                      onTap: () {
                        Navigator.of(context)
                            .push(transitionToNextScreen(const ChatPage()));
                      },
                    ),
                    // CustomTile(
                    //   icon: Padding(
                    //     padding: const EdgeInsets.all(5.0),
                    //     child: SvgPicture.asset(
                    //       'assets/svgs/flag.svg',
                    //       height: 16,
                    //       colorFilter: const ColorFilter.mode(
                    //           colorGreen, BlendMode.srcATop),
                    //     ),
                    //   ),
                    //   label: 'Report',
                    //   onTap: () {},
                    // )
                  ],
                )),
            const SizedBox(
              height: 25,
            ),
            // Container(
            //     padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.all(Radius.circular(20)),
            //         color: Color(0xffF6F8FA)),
            //     child: Column(
            //       children: [
            //         CustomTile(
            //           icon: Icon(
            //             Icons.help_outline,
            //             color: Color(0xffFB6D3A),
            //           ),
            //           label: 'FAQs',
            //           onTap: () {
            //             Navigator.of(context).push(
            //                 transitionToNextScreen(const HelpCentreScreen()));
            //           },
            //         ),
            //         CustomTile(
            //           icon: Padding(
            //             padding: const EdgeInsets.all(4.0),
            //             child: SvgPicture.asset(
            //               'assets/svgs/userReview.svg',
            //               height: 16,
            //             ),
            //           ),
            //           label: 'User Reviews',
            //           onTap: () {},
            //         ),
            //         CustomTile(
            //           icon: Icon(
            //             Icons.settings_outlined,
            //             color: Colors.blue,
            //           ),
            //           label: 'Settings',
            //           onTap: () {},
            //         )
            //       ],
            //     )),
            // const SizedBox(
            //   height: 25,
            // ),
            Container(
                padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color(0xffF6F8FA)),
                child: Column(
                  children: [
                    CustomTile(
                      icon: const Icon(
                        Icons.delete_forever_outlined,
                        color: colorRed,
                      ),
                      label: 'Delete Account',
                      onTap: () async {
                        // SharedPreferences prefs =
                        //     await SharedPreferences.getInstance();
                        // prefs.clear();
                        // prefs.setBool('isFirstLaunch', false);
                        // FirebaseAuth.instance.signOut();
                        // Navigator.of(context)
                        //     .popUntil((predicate) => predicate.isFirst);
                        // Navigator.of(context).pushReplacement(
                        //     transitionToNextScreen(const SignInScreen()));
                        showConfirmationPage();
                      },
                    ),
                    CustomTile(
                      icon: const Icon(
                        Icons.logout_outlined,
                        color: colorRed,
                      ),
                      label: 'Logout',
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? uid = prefs.getString('loginKey');
                        if (uid != null) {
                          FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            transaction.update(
                                FirebaseFirestore.instance
                                    .collection('fcmTokens')
                                    .doc('driver'),
                                {uid: FieldValue.delete()});
                          });
                        }
                        prefs.clear();
                        prefs.setBool('isFirstLaunch', false);
                        FirebaseAuth.instance.signOut();
                        WalletController.uid = '';
                        Navigator.of(context).pushAndRemoveUntil(
                            transitionToNextScreen(const SignInScreen()),
                            (_) => false);
                      },
                    ),
                  ],
                )),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
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
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorBrightRed),
                    child: const Text("Yes",
                        style: TextStyle(color: Colors.white))),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorBrightGreen),
                    child:
                        const Text("No", style: TextStyle(color: Colors.white)))
              ],
              actionsAlignment: MainAxisAlignment.spaceEvenly,
            ));
    if (confirm == true) {
      showLoadingPopup(context, "Deleting Account");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid')!;
      // String baseUrl = dotenv.env['BASE_URL']!;
      String baseUrl = AppStrings.baseURL;
      final response = await http.post(
          Uri.parse("$baseUrl/auth/deleteDeliveryBoyById"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': uid}));
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['executed']) {
          await WalletController.deleteWallet();
          Toast.showToast(message: "Account Deleted Successfully!");
          prefs.clear();
          prefs.setBool('isFirstLaunch', false);
          FirebaseAuth.instance.signOut();
          Navigator.of(context).popUntil((predicate) => predicate.isFirst);
          Navigator.of(context)
              .pushReplacement(transitionToNextScreen(const SignInScreen()));
        }
      }
    }
  }
}

class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    this.onTap,
    required this.icon,
    required this.label,
  });
  final GestureTapCallback? onTap;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          decoration:
              BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          padding: EdgeInsets.all(4),
          child: icon),
      title: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
    );
  }
}

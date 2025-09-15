import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/notification.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/Screens/Profile/aboutPage.dart';
import 'package:user_app/Screens/Profile/hiddenRestaurant.dart';
import 'package:user_app/Screens/Support/helpSupportScreen.dart';
import 'package:user_app/Screens/loginScreen.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/customs/Profile/profileButton.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Profile/editProfile.dart';
import 'package:user_app/screens/Profile/favouriteRestaurant.dart';
import 'package:user_app/screens/Profile/savedAddresses.dart';
import 'package:user_app/widgets/constants/navigation_extension.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/Profile/header.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/request_login.dart';
import 'package:user_app/widgets/customs/toasts.dart';
import 'package:user_app/widgets/loading_popup.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  UserModel? userModel;
  bool isUserInfoLoaded = false;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    setState(() {
      isUserInfoLoaded = false;
    });
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    var userResult =
        await UserController.getUserById(context: context, id: userId);
    userResult.fold((String text) {
      isUserInfoLoaded = true;
      if (mounted) {
        setState(() {});
      }
    }, (UserModel user) {
      isUserInfoLoaded = true;
      userModel = user;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        getUserInfo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: getUserInfo,
        child: !isUserInfoLoaded
            ? const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            : userModel == null
                ? loginRequest(context)
                : Stack(
                    children: [
                      Container(height: double.infinity),
                      Opacity(
                        opacity: 0.5,
                        child: Image.asset(
                          'assets/images/background.png',
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(top: 7.h, left: 3.w, right: 3.w),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              profileHeader(
                                  name: userModel!.user!.username ?? "",
                                  gender: userModel!.user!.gender,
                                  imageUrl: userModel!.user!.userImage,
                                  isdarkmode: isdarkmode),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isdarkmode
                                      ? const Color.fromARGB(255, 46, 45, 45)
                                      : const Color.fromARGB(
                                          255, 237, 238, 245),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    button(
                                        'Edit Profile',
                                        SvgPicture.asset(
                                          'assets/icons/editprofile.svg',
                                          height: 5.h,
                                        ), () async {
                                      context.push(EditProfile(
                                        userModel: userModel!.user!,
                                      ));
                                    }, context),
                                    const SizedBox(height: 10),
                                    button(
                                        'Favourites',
                                        SvgPicture.asset(
                                          'assets/icons/favouriote.svg',
                                          height: 5.h,
                                        ), () async {
                                      context.push(FavouriteRestaurants(
                                        userFavouriteRestaurantIds: userModel!
                                                .user!.favoriteRestaurants ??
                                            [],
                                        userLat: userModel!
                                                .user!.addresses![0].latitude ??
                                            0,
                                        userLng: userModel!.user!.addresses![0]
                                                .longitude ??
                                            0,
                                      ));
                                    }, context),
                                    const SizedBox(height: 10),
                                    button(
                                        'Hidden Restaurants',
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(180),
                                          child: Image.asset(
                                            'assets/images/hiddenres.png',
                                            height: 5.h,
                                          ),
                                        ), () async {
                                      context.push(const HiddenRestaurants());
                                    }, context),
                                    // const SizedBox(height: 10),
                                    // button(
                                    //   'Your Subscription',
                                    //   ClipRRect(
                                    //     borderRadius:
                                    //         BorderRadius.circular(180),
                                    //     child: Image.asset(
                                    //       'assets/images/sub.png',
                                    //       height: 5.h,
                                    //     ),
                                    //   ),
                                    //   () async {
                                    //     context.push(SubscriptionScreen());
                                    //   },
                                    //   context
                                    // ),
                                    const SizedBox(height: 10),
                                    button(
                                        'Saved Addresses',
                                        SvgPicture.asset(
                                          'assets/icons/address.svg',
                                          height: 5.h,
                                        ), () async {
                                      context.push(const SavedAddresses());
                                    }, context),
                                    const SizedBox(height: 10),
                                    button(
                                        'About',
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(180),
                                          child: Image.asset(
                                            'assets/images/about.png',
                                            height: 5.h,
                                          ),
                                        ), () async {
                                      context.push(const AboutPage());
                                    }, context),
                                    const SizedBox(height: 10),
                                    // button(
                                    //   'Send Feedback',
                                    //   ClipRRect(
                                    //     borderRadius: BorderRadius.circular(180),
                                    //     child: Image.asset(
                                    //       'assets/images/feedback.png',scale: 4,
                                    //     ),
                                    //   ),
                                    //   () async {
                                    //     context.push(const FeedbackScreen());
                                    //   },
                                    // ),
                                    // SizedBox(height: 10),
                                    button(
                                        'FAQs',
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(180),
                                          child: Image.asset(
                                            'assets/images/faq.png',
                                            height: 5.h,
                                          ),
                                        ), () async {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HelpSupportScreen(),
                                        ),
                                      );
                                    }, context),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isdarkmode
                                      ? const Color.fromARGB(255, 46, 45, 45)
                                      : const Color.fromARGB(
                                          255, 237, 238, 245),
                                ),
                                child: Column(
                                  children: [
                                    // FCM Token Test Button
                                    button(
                                        'Test iOS FCM Flow',
                                        Container(
                                            padding: const EdgeInsets.all(8),
                                            height: 5.h,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.blue),
                                            child: const Icon(
                                                Icons.notification_important,
                                                color: Colors.white)), () async {
                                      // Show loading dialog
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const AlertDialog(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 16),
                                              Text('Testing iOS FCM Flow...'),
                                            ],
                                          ),
                                        ),
                                      );

                                      // Run comprehensive FCM test
                                      Map<String, dynamic> testResults = await NotificationService.testIOSNotificationFlow();
                                      
                                      // Close loading dialog
                                      Navigator.pop(context);
                                      
                                      // Show results dialog
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('iOS FCM Flow Test Results'),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('📱 Platform: ${testResults['platform']}', 
                                                     style: const TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 8),
                                                
                                                Text('🔐 Permissions:', 
                                                     style: const TextStyle(fontWeight: FontWeight.bold)),
                                                Text('${testResults['permissions']}'),
                                                const SizedBox(height: 8),
                                                
                                                Text('🔑 Tokens:', 
                                                     style: const TextStyle(fontWeight: FontWeight.bold)),
                                                SelectableText('${testResults['tokens']}'),
                                                const SizedBox(height: 8),
                                                
                                                Text('🔥 Firestore:', 
                                                     style: const TextStyle(fontWeight: FontWeight.bold)),
                                                Text('${testResults['firestore']}'),
                                                const SizedBox(height: 8),
                                                
                                                if (testResults['errors'].isNotEmpty) ...[
                                                  Text('❌ Errors:', 
                                                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                                  Text('${testResults['errors']}'),
                                                  const SizedBox(height: 8),
                                                ],
                                                
                                                Text('📋 Summary:', 
                                                     style: const TextStyle(fontWeight: FontWeight.bold)),
                                                Text('${testResults['summary']}',
                                                     style: TextStyle(
                                                       color: testResults['summary'].contains('✅') 
                                                         ? Colors.green 
                                                         : testResults['summary'].contains('⚠️')
                                                           ? Colors.orange
                                                           : Colors.red,
                                                       fontWeight: FontWeight.bold
                                                     )),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                // Copy FCM token if available
                                                if (testResults['tokens']['fcmToken'] != null && 
                                                    testResults['tokens']['fcmToken'] != 'NULL') {
                                                  Clipboard.setData(ClipboardData(text: testResults['tokens']['fcmToken']));
                                                  Toast.showToast(message: 'FCM Token copied to clipboard');
                                                }
                                              },
                                              child: const Text('Copy FCM Token'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }, context),
                                    const SizedBox(height: 10),
                                    // Configuration Validation Button
                                    button(
                                        'Validate Notification Setup',
                                        Container(
                                            padding: const EdgeInsets.all(8),
                                            height: 5.h,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green),
                                            child: const Icon(
                                                Icons.checklist_outlined,
                                                color: Colors.white)), () async {
                                      // Show loading dialog
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const AlertDialog(
                                          content: Row(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 16),
                                              Text('Validating notification setup...'),
                                            ],
                                          ),
                                        ),
                                      );

                                      // Run comprehensive validation
                                      Map<String, dynamic> validationResults = await NotificationService.validateNotificationSetup();
                                      
                                      // Close loading dialog
                                      Navigator.pop(context);
                                      
                                      // Calculate overall status
                                      int failedTests = 0;
                                      int warningTests = 0;
                                      int totalTests = validationResults.length;
                                      
                                      validationResults.forEach((test, result) {
                                        String status = result['status'];
                                        if (status == 'error') failedTests++;
                                        else if (status == 'warning') warningTests++;
                                      });
                                      
                                      Color statusColor = failedTests == 0 && warningTests == 0 
                                          ? Colors.green 
                                          : failedTests == 0 
                                            ? Colors.orange 
                                            : Colors.red;
                                      
                                      String statusIcon = failedTests == 0 && warningTests == 0 
                                          ? '✅' 
                                          : failedTests == 0 
                                            ? '⚠️' 
                                            : '❌';
                                      
                                      // Show detailed results dialog
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Row(
                                            children: [
                                              Text(statusIcon),
                                              const SizedBox(width: 8),
                                              const Expanded(child: Text('Notification Setup Validation')),
                                            ],
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Overall Status
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: statusColor),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('📊 OVERALL STATUS', 
                                                           style: const TextStyle(fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 4),
                                                      Text('✅ Passed: ${totalTests - failedTests - warningTests}/$totalTests'),
                                                      Text('⚠️ Warnings: $warningTests/$totalTests'),
                                                      Text('❌ Failed: $failedTests/$totalTests'),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                
                                                // Detailed Results
                                                ...validationResults.entries.map((entry) {
                                                  String testName = entry.key;
                                                  Map<String, dynamic> testResult = entry.value;
                                                  String status = testResult['status'];
                                                  List<dynamic> issues = testResult['issues'] ?? [];
                                                  Map<String, dynamic> details = testResult['details'] ?? {};
                                                  
                                                  String emoji = status == 'success' ? '✅' : 
                                                                status == 'warning' ? '⚠️' : 
                                                                status == 'error' ? '❌' : '❓';
                                                  
                                                  Color testColor = status == 'success' ? Colors.green : 
                                                                   status == 'warning' ? Colors.orange : 
                                                                   status == 'error' ? Colors.red : Colors.grey;
                                                  
                                                  return Container(
                                                    margin: const EdgeInsets.only(bottom: 12),
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: testColor.withOpacity(0.05),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: testColor.withOpacity(0.3)),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(emoji),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                testName.toUpperCase(),
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: testColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (details.isNotEmpty) ...[
                                                          const SizedBox(height: 4),
                                                          ...details.entries.map((detail) => 
                                                            Text('• ${detail.key}: ${detail.value}',
                                                                 style: const TextStyle(fontSize: 12))),
                                                        ],
                                                        if (issues.isNotEmpty) ...[
                                                          const SizedBox(height: 4),
                                                          ...issues.map((issue) => 
                                                            Text('⚠️ $issue',
                                                                 style: TextStyle(fontSize: 12, color: Colors.red.shade700))),
                                                        ],
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                                
                                                // Configuration Summary
                                                if (validationResults.containsKey('firebase') && 
                                                    validationResults['firebase']['details'] != null) ...[
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text('🔥 FIREBASE CONFIGURATION SUMMARY',
                                                                 style: TextStyle(fontWeight: FontWeight.bold)),
                                                        const SizedBox(height: 8),
                                                        SelectableText('App ID: ${validationResults['firebase']['details']['appId'] ?? 'N/A'}',
                                                                       style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                                                        SelectableText('Project ID: ${validationResults['firebase']['details']['projectId'] ?? 'N/A'}',
                                                                       style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                                                        if (validationResults['bundleId']['details'] != null)
                                                          SelectableText('Bundle ID: ${validationResults['bundleId']['details']['firebase'] ?? 'N/A'}',
                                                                         style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            if (validationResults.containsKey('fcmToken') && 
                                                validationResults['fcmToken']['details'] != null &&
                                                validationResults['fcmToken']['details']['fcmToken'] != null &&
                                                validationResults['fcmToken']['details']['fcmToken'] != 'null')
                                              TextButton(
                                                onPressed: () {
                                                  Clipboard.setData(ClipboardData(
                                                    text: validationResults['fcmToken']['details']['fcmToken']
                                                  ));
                                                  Toast.showToast(message: 'FCM Token copied to clipboard');
                                                },
                                                child: const Text('Copy FCM Token'),
                                              ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }, context),
                                    const SizedBox(height: 10),
                                    button(
                                        'Delete Account',
                                        Container(
                                            padding: const EdgeInsets.all(8),
                                            height: 5.h,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                            child: const Icon(
                                                Icons.delete_forever_outlined,
                                                color: Colors.red)), () async {
                                      // Navigator.pushAndRemoveUntil(
                                      //     context,
                                      //     transitionToNextScreen(
                                      //         const LoginScreen()),
                                      //     (route) => false);
                                      showConfirmationPage();
                                    }, context),
                                    button(
                                        'Logout',
                                        SvgPicture.asset(
                                          'assets/icons/logout.svg',
                                          height: 5.h,
                                        ), () async {
                                      final baseUrl = SharedPrefsUtil()
                                          .getString("base_url")!;
                                      await FirebaseFirestore.instance
                                          .runTransaction((transaction) async {
                                        transaction.update(
                                            FirebaseFirestore.instance
                                                .collection('fcmTokens')
                                                .doc('user'),
                                            {
                                              SharedPrefsUtil().getString(
                                                      AppStrings.userId)!:
                                                  FieldValue.delete()
                                            });
                                      });
                                      await SharedPrefsUtil().clear();
                                      await SharedPrefsUtil()
                                          .setString('base_url', baseUrl);
                                      context.read<GlobalProvider>().clear();

                                      FirebaseAuth.instance.signOut();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          transitionToNextScreen(
                                              const LoginScreen()),
                                          (route) => false);
                                    }, context),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  void showConfirmationPage() async {
    final proceed = await showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: const Text(
                "Are you sure you want to delete your account? This action cannot be undone.",
                style: TextStyle(fontSize: 18),
              ),
              content: const Text('''
Deleting you account will :-
  1. Delete all your data from our server.
  2. Make you lose all your current wallet cash.
  3. Delete all your orders and active complaints.

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
    if (proceed == true) {
      // String baseUrl = dotenv.env['BASE_URL']!;
      showLoadingPopup(context, "Deleting Account...");
      String baseUrl = SharedPrefsUtil().getString('base_url')!;
      final response = await post(Uri.parse("$baseUrl/auth/deleteUser"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'uid': SharedPrefsUtil().getString(AppStrings.userId)}));
      if (response.statusCode == 200) {
        Toast.showToast(message: "Account Deleted Successfully!");
        await WalletController.deleteWallet();
        SharedPrefsUtil().clear();
        await SharedPrefsUtil().setString('base_url', baseUrl);
        context.read<GlobalProvider>().clear();
        FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(context,
            transitionToNextScreen(const LoginScreen()), (route) => false);
      }
    }
  }
}

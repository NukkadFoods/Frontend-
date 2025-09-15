import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Controller/notification.dart';
import 'package:restaurant_app/Controller/wallet_controller.dart';
// import 'package:restaurant_app/Screens/AccessibilityTab/complain_page.dart';
import 'package:restaurant_app/Screens/new_screens/no_internet_connection_screen.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:sizer/sizer.dart';
import 'Screens/Navbar/menuBody.dart';
import 'Screens/Navbar/homeBody.dart';
import 'Screens/Navbar/orderBody.dart';
import 'Screens/Navbar/walletBody.dart';
import 'Widgets/constants/colors.dart';
import 'Widgets/constants/texts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isConnected = true, isLoading = true;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeBody(),
    const MenuBody(),
    const OrderBody(),
    const WalletBody(),
    // const ComplaintsWidget(),
  ];
  @override
  void initState() {
    super.initState();
    NotificationService.init(_onItemTapped);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetConnection();
    });
    fetchRestaurantDetails();
    WalletController.getWallet();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      setState(() {
        isConnected = false;
      });
    } else {
      setState(() {
        isConnected = true;
      });
    }

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void fetchRestaurantDetails() async {
    bool success = await LoginController.getRestaurantByID(
      uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
      context: context,
    );

    if (success) {
      print("""Restaurant details fetched successfully.""");
      if (_auth.currentUser == null) {
        String contact = SharedPrefsUtil().getString(AppStrings.mobilenumber)!;
        if (contact.startsWith('+91')) {
          contact = contact.substring(3);
        }
        await _auth
            .signInWithEmailAndPassword(
                email: '$contact@gmail.com', password: contact)
            .onError((e, _) {
          // if (e is FirebaseAuthException) {
          print(contact);
          return _auth.createUserWithEmailAndPassword(
              email: '$contact@gmail.com', password: contact);
          // }
        });

        log('Firebase login successfull');
      } else {
        log("already logged in");
      }
    } else {
      // Handle failure scenario, if needed.
      print('Failed to fetch restaurant details.');
    }

    //Check for launch from background

    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null && message.data['orderId'] != null) {
      _selectedIndex = 2;
    }

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
    // final subscription = await SubscribeController.getSubscriptionById(
    //     context: context, id: SharedPrefsUtil().getString(AppStrings.userId)!);
    // if (subscription == null) {
    //   _showBottomSheet();
    // } else {
    //   final endDate =
    //       DateTime.parse(subscription.startDate).add(const Duration(days: 120));
    //   if (endDate.isAfter(DateTime.now())) {
    //     _showBottomSheet();
    //   }
    // }
  }

  // void _showBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Allow the bottom sheet to be scrollable
  //     builder: (BuildContext context) {
  //       return Container(
  //         height: 95.h,
  //         // padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //           color: textWhite,
  //         ),
  //         child: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               Align(
  //                 alignment: Alignment.center,
  //                 child: IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //               ),
  //               const SubscribeCard(),
  //               Padding(
  //                 padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.h),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     Container(
  //                       height: 55.h,
  //                       width: 95.w,
  //                       padding: EdgeInsets.symmetric(
  //                           horizontal: 3.w, vertical: 2.h),
  //                       decoration: BoxDecoration(
  //                         border: Border.all(width: 0.2.h, color: primaryColor),
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(7),
  //                       ),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             child: Lottie.asset(
  //                                 'assets/animations/subscribe.json'),
  //                             height: 25.h,
  //                           ),
  //                           Text(
  //                             'Subscribe to Nukkad foods',
  //                             style: body3TextStyle.copyWith(
  //                                 color: primaryColor,
  //                                 fontWeight: FontWeight.bold),
  //                             textAlign: TextAlign.center,
  //                           ),
  //                           SizedBox(height: 2.h),
  //                           Container(
  //                             width: 60.w,
  //                             child: Column(
  //                               children: [
  //                                 // _buildRow('2x New customers'),
  //                                 // SizedBox(height: 2.h),
  //                                 // _buildRow('3x Repeat customers'),
  //                                 // SizedBox(height: 2.h),
  //                                 _buildRow('More Orders'),
  //                                 SizedBox(height: 2.h),
  //                                 _buildRow('More Earnings'),
  //                                 // SizedBox(height: 2.h),
  //                                 // RichText(
  //                                 //     text: TextSpan(children: const [
  //                                 //   TextSpan(
  //                                 //       text: "Note :- ",
  //                                 //       style: TextStyle(
  //                                 //           fontWeight: FontWeight.w500)),
  //                                 //   TextSpan(
  //                                 //       text: "In order to receive orders a Nukkad must have a Subscription",
  //                                 //       style: TextStyle(
  //                                 //           fontWeight: FontWeight.w500))
  //                                 // ]))
  //                               ],
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: 2.h),
  //                     Padding(
  //                       padding: EdgeInsets.only(bottom: 2.h),
  //                       child: mainButton('Subscribe at just ₹ 399', textWhite,
  //                           () {
  //                         //   String time = DateTime.now().toIso8601String();
  //                         //   final subscribeRequest = SubscribeRequestModel(
  //                         //       subscribeById: SharedPrefsUtil()
  //                         //           .getString(AppStrings.userId)!,
  //                         //       role: 'Restaurant',
  //                         //       subscriptionPlanId: '399 - 4 Month',
  //                         //       startDate: time);
  //                         //   SubscribeController.subscribeUser(
  //                         //       context: context,
  //                         //       subscribeRequest: subscribeRequest);
  //                         //
  //                         Navigator.of(context).pushReplacement(
  //                             transitionToNextScreen(CheckoutScreen(
  //                           amount: 399,
  //                           itemToBePurchased: "Subscription",
  //                           onPaymentSuccess: () async {
  //                             String time = DateTime.now().toIso8601String();
  //                             final subscribeRequest = SubscribeRequestModel(
  //                                 subscribeById: SharedPrefsUtil()
  //                                     .getString(AppStrings.userId)!,
  //                                 role: 'Restaurant',
  //                                 subscriptionPlanId: '399 - 4 Month',
  //                                 startDate: time);
  //                             return await SubscribeController.subscribeUser(
  //                                 context: context,
  //                                 subscribeRequest: subscribeRequest);
  //                           },
  //                         )));
  //                       }),
  //                     ),
  //                     Align(
  //                       alignment: Alignment.center,
  //                       child: Padding(
  //                         padding: EdgeInsets.only(top: 1.h, bottom: 2.h),
  //                         child: Text(
  //                           'For 4 Month',
  //                           style: body4TextStyle.copyWith(
  //                               color: primaryColor,
  //                               fontSize: 15.sp,
  //                               fontWeight: FontWeight.w600),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (!isConnected) {
      return const NoInternetConnectionScreen(); // Show No Internet screen
    }
    return Scaffold(
      body: isLoading
          ? Center(child: const CircularProgressIndicator())
          : Center(
              child: _widgetOptions[_selectedIndex],
            ),
      bottomNavigationBar: SafeArea(
        child: CustomAppBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomAppBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20), // Rounded corners on top
      ),
      child: Container(
        color: textWhite,
        height: 8.6.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildNavBarItem(
              icon: 'assets/icons/navbar_home..svg',
              label: 'Analytics',
              index: 0,
            ),
            _buildNavBarItem(
              icon: 'assets/icons/navbar_menu.svg',
              label: 'Menu',
              index: 1,
            ),
            _buildNavBarItem(
              icon: 'assets/icons/navbar_order.svg',
              label: 'Orders',
              index: 2,
            ),
            _buildNavBarItem(
              icon: 'assets/icons/navbar_wallet.svg',
              label: 'Wallet',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
      {required String icon, required String label, required int index}) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isSelected)
            Container(
              width: 40, // Width of the line
              height: 4, // Height of the line
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
              margin: EdgeInsets.only(bottom: 4), // Margin below the line
            ),
          SizedBox(height: 1.5.h), // Space between line and icon
          SvgPicture.asset(
            icon,
            color: isSelected ? primaryColor : textGrey2,
            height: 2.5.h,
            width: 2.5.h,
          ),
          SizedBox(height: 2), // Space between icon and label
          Text(
            label,
            style: isSelected
                ? body4TextStyle.copyWith(color: primaryColor)
                : body4TextStyle.copyWith(color: textGrey2),
          ),
        ],
      ),
    );
  }
}

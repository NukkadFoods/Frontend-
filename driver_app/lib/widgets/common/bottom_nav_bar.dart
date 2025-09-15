import 'dart:developer';

import 'package:driver_app/controller/location_broadcast.dart';
import 'package:driver_app/controller/notification.dart';
import 'package:driver_app/controller/wallet_controller.dart';
import 'package:driver_app/screens/home_screens/home_screen.dart';
import 'package:driver_app/screens/orders_screen.dart';
import 'package:driver_app/screens/other_screens/wallet_screen.dart';
import 'package:driver_app/screens/profile/profile_screen.dart';
import 'package:driver_app/screens/report_screens/report_screen.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  var deliveryboyData;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> navBarContent = [
    {'label': 'Home', 'iconPath': 'assets/svgs/home.svg'},
    {'label': 'Orders', 'iconPath': 'assets/svgs/order.svg'},
    {'label': 'Analytics', 'iconPath': 'assets/svgs/analytics.svg'},
    {'label': 'Wallet', 'iconPath': 'assets/svgs/wallet.svg'},
    {'label': 'Profile', 'iconPath': 'assets/svgs/profile.svg'},
  ];
  final LocationBroadcast location = LocationBroadcast();
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    OrdersScreen(),
    ReportScreen(),
    WalletScreen(),
    MyProfileScreen(),
  ];

  // void getDeliveryBoyData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   deliveryboyData = prefs.getString('deliveryBoyData');
  //   if (deliveryboyData != null) {
  //     deliveryboyData = jsonDecode(deliveryboyData);
  //   }
  // }

  void login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firebase = prefs.getString('firebase');
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

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser == null) {
      log('User not logged in logging in...');
      login();
    } else {
      log('user already logged in...');
    }
    NotificationService.init();
    WalletController.getWallet();
  }

  @override
  Widget build(BuildContext context) {
    double navHeight = 60;
    double iosPadding = 15;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              if (defaultTargetPlatform == TargetPlatform.iOS)
                SizedBox(
                  height: iosPadding,
                ),
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/otpbbg.png'),
                        fit: BoxFit.cover,
                        opacity: .5)),
                height: constraints.maxHeight - navHeight - iosPadding,
                width: MediaQuery.of(context).size.width,
                child: _widgetOptions[_selectedIndex],
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                height: navHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < 5; i++)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = i;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // _selectedIndex == i
                            //     ?
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _selectedIndex == i ? 40 : 0,
                              height: 3,
                              decoration: BoxDecoration(
                                  color: colorGreen,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(3),
                                      bottomRight: Radius.circular(3))),
                            ),
                            // : SizedBox(
                            //     height: 3,
                            //   ),
                            SvgPicture.asset(
                              navBarContent[i]['iconPath'],
                              height: _selectedIndex == i ? 30 : 25,
                              color:
                                  _selectedIndex == i ? colorGreen : colorGray,
                            ),
                            Text(
                              navBarContent[i]['label'],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedIndex == i
                                      ? colorGreen
                                      : colorGray),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      //_widgetOptions.elementAt(_selectedIndex)
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: Colors.white,
      //   showUnselectedLabels: true,
      //   items: <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.white,
      //       icon: SvgPicture.asset(
      //         'assets/svgs/order.svg',
      //         color: _selectedIndex == 0 ? colorGreen : colorGray,
      //       ),
      // activeIcon: Column(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     Container(
      //       width: double.infinity,
      //       height: 3,
      //       decoration: BoxDecoration(
      //           color: colorGreen,
      //           borderRadius: BorderRadius.only(
      //               bottomLeft: Radius.circular(3),
      //               bottomRight: Radius.circular(3))),
      //     ),
      //     SvgPicture.asset(
      //       'assets/svgs/order.svg',
      //       color: _selectedIndex == 0 ? colorGreen : colorGray,
      //     )
      //   ],
      // ),
      //       label: 'Orders',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: SvgPicture.asset(
      //         'assets/svgs/analytics.svg',
      //         color: _selectedIndex == 1 ? colorGreen : colorGray,
      //       ),
      //       label: 'Report',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: SvgPicture.asset(
      //         'assets/svgs/wallet.svg',
      //         color: _selectedIndex == 2 ? colorGreen : colorGray,
      //       ),
      //       label: 'Wallet',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: SvgPicture.asset(
      //         'assets/svgs/profile.svg',
      //         color: _selectedIndex == 3 ? colorGreen : colorGray,
      //       ),
      //       label: 'Profile',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: colorGreen,
      //   unselectedItemColor: colorGray,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   child: Center(
    //     child: Text('Business Screen'),
    //   ),
    // );
    return Scaffold(
      bottomNavigationBar:
          BottomNavigationBar(items: <BottomNavigationBarItem>[]),
    );
  }
}

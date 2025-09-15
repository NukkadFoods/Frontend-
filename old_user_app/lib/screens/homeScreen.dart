import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/notification.dart';
import 'package:user_app/Controller/subscription_resquest.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/NavBarWidgets/foodBody.dart';
import 'package:user_app/screens/NavBarWidgets/orderBody.dart';
import 'package:user_app/screens/NavBarWidgets/profileBody.dart';
import 'package:user_app/screens/NavBarWidgets/walletBody.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_app/widgets/customs/home/cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _auth = FirebaseAuth.instance;
  // Widget list
  List<Widget> _widgetOptions = [];

  // Create a GlobalKey for the OrdersBody widget
  Key ordersBodyKey = UniqueKey();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Reload OrdersBody every time it's selected by changing its key
      if (index == 1) {
        ordersBodyKey = UniqueKey(); // Assign a new key to force rebuild
        _widgetOptions[1] = OrdersBody(key: ordersBodyKey);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (SharedPrefsUtil().getString(AppStrings.userId) != null) {
      SubscribeController.getSubscriptionById(
          context: context,
          id: SharedPrefsUtil().getString(AppStrings.userId)!);
      WalletController.getWallet();
    }
    if (_auth.currentUser == null) {
      createUser();
      log('User not logged in logging in...');
      login();
    } else {
      log('user already logged in...');
    }
    NotificationService.init();
    // Initialize widget options list
    _widgetOptions = <Widget>[
      const FoodBody(),
      OrdersBody(key: ordersBodyKey), // Add Key to OrdersBody
      const WalletBody(),
      const ProfileBody(),
    ];
  }

  Future<void> createUser() async {
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '$userId@gmail.com',
        password: 'firebase',
      );
      print('User created successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  void login() async {
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";

    try {
      await _auth.signInWithEmailAndPassword(
          email: '$userId@gmail.com', password: 'firebase');
      print('logged in to Firebase');
    } catch (e) {
      print('Login error in firebase');
    }
    // _user = userCredential.user;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      )),
      child: Scaffold(
        body: Center(
          child: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
        ),
        bottomNavigationBar: CustomAppBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
        bottomSheet: Consumer<GlobalProvider>(
          builder: (context, value, child) {
            if (_selectedIndex == 0 && (value.restaurants != null)) {
              return StackedCarts(value: value);
              // } else if (_selectedIndex == 0 &&
              //     (value.restaurants != null && value.ongoingOrders.isNotEmpty)) {
              //   return OngoingOrdersCards(value: value);
            } else {
              log('sizedbox');
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomAppBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20), // Rounded corners on top
      ),
      child: Container(
        height: 8.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildNavBarItem(
              icon: 'assets/icons/navbarhom.svg',
              label: 'Home',
              index: 0,
            ),
            _buildNavBarItem(
              icon: 'assets/icons/orders_icon.svg',
              label: 'Orders',
              index: 1,
            ),
            _buildNavBarItem(
              icon: 'assets/icons/navbarwallet.svg',
              label: 'Wallet',
              index: 2,
            ),
            _buildNavBarItem(
              icon: 'assets/icons/navbarprofile.svg',
              label: 'Profile',
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
              width: 10.w, // Width of the line
              height: 0.5.h, // Height of the line
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
              margin: const EdgeInsets.only(bottom: 4), // Margin below the line
            ),
          SizedBox(height: 1.5.h), // Space between line and icon
          SvgPicture.asset(
            icon,
            color: isSelected ? primaryColor : textGrey2,
            height: 2.3.h,
            width: 2.3.h,
          ),
          const SizedBox(height: 2), // Space between icon and label
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

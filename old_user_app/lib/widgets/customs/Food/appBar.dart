// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/subscription_resquest.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/screens/NavBarWidgets/profileBody.dart';
import 'package:user_app/screens/Profile/savedAddresses.dart';
import 'package:user_app/screens/Subscriptions/subscription.dart';
import 'package:user_app/screens/Subscriptions/subscriptionplan.dart';
import 'package:user_app/widgets/customs/Theme.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    super.key,
    required this.savedAs,
    required this.address,
    required this.onAddressSelected,
  });

  final String savedAs;
  final String address;
  final Function onAddressSelected;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  String selectedSaveAs = '';
  String selectedAddress = '';
  String prefsSaveAs = '';
  String prefsAddress = '';

  @override
  void initState() {
    super.initState();
    getAddressSelected();
  }

  // Function to get the selected address type and details from SharedPreferences
  Future<void> getAddressSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefsAddress = prefs.getString('CurrentAddress') ?? "";
      prefsSaveAs = prefs.getString('CurrentSaveAs') ?? "";
    });
  }

  // Function to handle the selected address
  void handleAddressSelection(Map<String, String?> addressData) {
    setState(() {
      selectedAddress = addressData['address']!;
      selectedSaveAs = addressData['saveAs']!;
    });
    widget.onAddressSelected();
  }

  // Toggle between light and dark theme using ThemeProvider
  void toggleTheme() async {
    final apptheme = Provider.of<Themes>(context, listen: false);
    apptheme.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Show loading indicator if values are not fetched yet
    if (prefsSaveAs.isEmpty && prefsAddress.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: primaryColor));
    }

    // Determine the display values for saveAs and address
    String displaySaveAs = selectedSaveAs.isNotEmpty
        ? selectedSaveAs
        : (prefsSaveAs.isNotEmpty ? prefsSaveAs : widget.savedAs);
    String displayAddress = selectedAddress.isNotEmpty
        ? selectedAddress
        : (prefsAddress.isNotEmpty ? prefsAddress : widget.address);

    return Container(
      margin: EdgeInsets.only(top: 5.h, right: 1.8.w, left: 3.w),
      height: 9.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 1.h, 1.w, 2.h),
            child: SvgPicture.asset(
              'assets/icons/location_pin_icon.svg',
              height: 4.h,
              color: primaryColor,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displaySaveAs,
                        style: h5TextStyle.copyWith(
                            color: isDarkMode ? textWhite : textBlack),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        displayAddress,
                        style: body5TextStyle.copyWith(
                            color: isDarkMode ? textWhite : textBlack),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      transitionToNextScreen(SavedAddresses(
                        onAddressSelected: handleAddressSelection,
                        address: displayAddress,
                        saveAs: displaySaveAs,
                      )),
                    );
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/dropdown_icon.svg',
                    height: 3.5.h,
                    color: isDarkMode ? textWhite : textBlack,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: toggleTheme,
            child: SvgPicture.asset(
              'assets/icons/darkbutton.svg',
              height: 4.5.h,
              width: 4.5.h,
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       transitionToNextScreen(const ProfileBody()),
          //     );
          //   },
          //   icon: SvgPicture.asset('assets/icons/user.svg'),
          // ),
          IconButton(
            onPressed: () {
              if (SubscribeController.subscription == null) {
                Navigator.push(
                  context,
                  transitionToNextScreen(const SubscriptionPlanScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  transitionToNextScreen(const SubscriptionScreen()),
                );
              }
            },
            icon: SvgPicture.asset('assets/icons/rewards_icon.svg'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/map/map.dart';
import 'package:user_app/screens/enter_location.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key, required this.isAdd});
  final bool isAdd;

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  void routemap() {
    Navigator.push(
      context,
      transitionToNextScreen(MapsScreen(
        loginSkipped: false,
        add: widget.isAdd,
      )),
    );
  }

  void routeenterlocation() {
    Navigator.of(context)
        .push(transitionToNextScreen(EnterLocation(isAdd: widget.isAdd)));
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
              height: 100.h,
              width: 100.w,
              child: Column(
                children: [
                  SizedBox(height: 5.h),
                  Text(
                    "What’s your location?",
                    style: h1TextStyle.copyWith(
                      color: primaryColor,
                      fontSize: 20.sp,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8.h, bottom: 6.h, left: 4.w, right: 4.w),
                    child: Text(
                      'Location needed to show stalls/ food trucks near you and deliver to you accurately.',
                      style: body2TextStyle.copyWith(
                        fontSize: 13.sp,
                        color: isdarkmode ? textWhite : textBlack,
                        fontWeight: FontWeight.w100,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: mainButton(
                        'Allow Location Access', Colors.white, routemap),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent,
                      ),
                    ),
                    onPressed: routeenterlocation,
                    child: Text(
                      'Enter Location Manually',
                      style: h5TextStyle.copyWith(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/location screen image.jpg',
              height: 40.h,
              width: 100.w,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

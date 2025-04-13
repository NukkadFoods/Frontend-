import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/texts.dart';

Widget referalMap() {
  return Container(
    height: 94.h,
    width: 100.w,
    padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            border: Border.all(width: 0.2.h, color: textGrey2),
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset('assets/images/refer_1.png'),
              SizedBox(
                width: 40.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1.',
                        style: h3TextStyle.copyWith(color: primaryColor)),
                    Text('Share referral link using Whatsapp, SMS, and more.',
                        style: body4TextStyle)
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            border: Border.all(width: 0.2.h, color: textGrey2),
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 50.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2.',
                      style: h3TextStyle.copyWith(color: primaryColor),
                    ),
                    Text(
                      'Your friend clicks on the link to download the Nukkad app or uses your referral code!',
                      style: body4TextStyle,
                    )
                  ],
                ),
              ),
              Image.asset(
                'assets/images/refer_2.png',
                scale: 1.1,
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            border: Border.all(width: 0.2.h, color: textGrey2),
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/refer_3.png'),
              SizedBox(
                width: 40.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3.',
                        style: h3TextStyle.copyWith(color: primaryColor)),
                    Text('Friend places their first order.',
                        style: body4TextStyle)
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          height: 22.h,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            border: Border.all(width: 0.2.h, color: textGrey2),
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -15,
                right: 40,
                child: Image.asset('assets/images/refer_4.png'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4.',
                    style: h3TextStyle.copyWith(color: primaryColor),
                  ),
                  SizedBox(
                    width: 75.w,
                    child: Text(
                        'You both earn 50 wallet cash each, that can be used while placing orders. ',
                        style: body4TextStyle),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

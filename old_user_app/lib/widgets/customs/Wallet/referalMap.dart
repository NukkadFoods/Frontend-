import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

Widget referalMap(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  return Container(
    height: 78.h,
    width: 99.w,
    padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 15.h,
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            border: Border.all(width: 0.2.h, color: textGrey2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/refer_1.png'),
              SizedBox(
                width: 40.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1.',
                        style: h5TextStyle.copyWith(color: primaryColor)),
                    Text('Share referral link using Whatsapp, SMS, and more.',
                        style: body5TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack))
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          height: 15.h,
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            border: Border.all(width: 0.2.h, color: textGrey2),
          
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 45.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2.',
                        style: h5TextStyle.copyWith(color: primaryColor)),
                    Text(
                        'Your friend clicks on the link to download the Nukkad app or uses your referral code!',
                        style: body5TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack))
                  ],
                ),
              ),
              Image.asset('assets/images/refer_2.png',),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          height: 15.h,
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            border: Border.all(width: 0.2.h, color: textGrey2),
          
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
                        style: h5TextStyle.copyWith(color: primaryColor)),
                    Text('Friend places their first order.',
                        style: body5TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack))
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          height: 20.h,
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            border: Border.all(width: 0.2.h, color: textGrey2),
      
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -10,
                right: 40,
                child: Image.asset('assets/images/refer_4.png'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '4.',
                    style: h5TextStyle.copyWith(color: primaryColor),
                  ),
                  SizedBox(
                    width: 70.w,
                    child: Text(
                        'You both earn 50 wallet cash each, that can be used while placing orders. ',
                        style: body5TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

Widget couponWidget({required Function(String) onApplyCoupon}) {
  TextEditingController couponController = TextEditingController(); // Controller for the text field

  return Container(
    height: 13.h,
    margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    decoration: BoxDecoration(
      color: textWhite,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: textGrey2,
        width: 0.2.h,
      ),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Coupons',
              style: body4TextStyle.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 3.w),
            SvgPicture.asset(
              'assets/icons/coupon_icon.svg',
              height: 4.h,
            ),
          ],
        ),
        Container(
          height: 6.h,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.w,
                margin: EdgeInsets.symmetric(vertical: 0.5.h),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  color: textGrey2,
                ),
                child: TextField(
                  controller: couponController, // Use the controller to get the text
                  decoration: InputDecoration(
                    label: Text(
                      'Enter coupon code',
                      style: body5TextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.w),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  String enteredCoupon = couponController.text;
                  onApplyCoupon(enteredCoupon); // Pass the entered coupon to the callback
                },
                child: Container(
                  width: 25.w,
                  padding: EdgeInsets.symmetric(vertical: 1.3.h),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: h6TextStyle.copyWith(
                      color: textBlack,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

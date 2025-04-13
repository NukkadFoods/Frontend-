import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/toasts.dart';

Widget couponButton(BuildContext context, String couponCode) {
  // The code to copy

  return SizedBox(
    child: Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: primaryColor,
          border: Border.all(width: 0.2.h, color: primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Copy your code',
              style: h5TextStyle.copyWith(
                color: textWhite,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              couponCode,
              style: h5TextStyle.copyWith(fontSize: 13.sp),
            ),
            IconButton(
              onPressed: () {
                // Copy the coupon code to clipboard
                Clipboard.setData(ClipboardData(text: couponCode)).then((_) {
                  Toast.showToast(message: "Code Copied!");
                });
              },
              icon: Icon(
                Icons.copy_outlined,
                color: textWhite,
                size: 16.sp,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

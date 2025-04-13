import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import Clipboard package
import 'package:path/path.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/texts.dart';

Widget couponButton(BuildContext context,String couponCode){
  // The code to copy

  return SizedBox(
    child: Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
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
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              couponCode,
              style: h5TextStyle.copyWith(fontSize: 14.sp),
            ),
            IconButton(
              onPressed: () {
                // Copy the coupon code to clipboard
                Clipboard.setData(ClipboardData(text: couponCode)).then((_) {
                });
              },
              icon: Icon(
                Icons.copy_outlined,
                color: textWhite,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

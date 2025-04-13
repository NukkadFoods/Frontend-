import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

Widget totalWidget(bool isdarkmode,{required double total, required double actualprice}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 4.w),
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xff5ee74c),
          Color(0xff30b82d),
          Color(0xff0c9015),
        ],
      ),
    ),
    child: Row(
      children: [
        Text(
          'Grand Total'.toUpperCase(),
          style: body2TextStyle.copyWith(
            color: isdarkmode ? textBlack: textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '₹${ (1+ actualprice).toStringAsFixed(0)}',
          style: body4TextStyle.copyWith(
            fontSize: 13.sp,
            color: textGrey2,
            decoration: TextDecoration.lineThrough,
            decorationColor: textGrey2,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          '₹${total.toStringAsFixed(1)}',
          style: body2TextStyle.copyWith(
            color:isdarkmode ? textBlack: textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

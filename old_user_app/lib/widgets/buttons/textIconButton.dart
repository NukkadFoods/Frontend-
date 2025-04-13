import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

Widget textIconButton(String text, Function() onTap, bool isdarkmode) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: body4TextStyle.copyWith(
                color: isdarkmode ? textGrey2 : textBlack,
                fontWeight: FontWeight.bold,
                fontSize: 9.sp,
                overflow: TextOverflow.ellipsis),
          ),
        ),
        SizedBox(width: 5.sp),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2), color: primaryColor),
          child: Icon(Icons.add,
              color: isdarkmode ? textBlack : textWhite, size: 12.sp),
        ),
      ],
    ),
  );
}

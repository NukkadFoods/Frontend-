import 'package:flutter/material.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

Widget noteWidget(String message) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: const Color(0xffff7f6ce),
      border: Border.all(
        color: const Color(0xFFFFC000),
      ),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Note: ',
            style: body4TextStyle.copyWith(
              fontSize: 14.sp,
              color: const Color(0xFFD00000),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: message,
            style: body4TextStyle.copyWith(
                fontSize: 12.sp, fontWeight: FontWeight.w100),
          ),
        ],
      ),
      maxLines: 4,
      textAlign: TextAlign.justify,
    ),
  );
}

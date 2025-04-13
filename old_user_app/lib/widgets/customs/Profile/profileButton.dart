import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/constants/colors.dart';

Widget button(String text, Widget icon, Future<void> Function() route,
    BuildContext context) {
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0),
    child: GestureDetector(
      onTap: () async {
        await route();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: icon,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              text,
              style: isdarkmode
                  ? body1TextStyle.copyWith(
                    
                      fontSize: 12.sp,
                      color: textGrey2)
                  : body1TextStyle.copyWith(
                     fontSize: 12.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isdarkmode ? textGrey2 : textBlack,
          ),
          SizedBox(width: 10)
        ],
      ),
    ),
  );
}

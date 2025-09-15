import 'package:flutter/material.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

Widget textRichButton(String text1, String text2, Function() route) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(text1, style: body4TextStyle.copyWith(color: textGrey2)),
      TextButton(
        onPressed: route,
        style: const ButtonStyle(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        child: Text(
          text2,
          style: body4TextStyle.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    ],
  );
}

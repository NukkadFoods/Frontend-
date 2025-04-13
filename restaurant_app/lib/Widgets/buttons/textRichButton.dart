import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';

Widget textRichButton(String text1, String text2, Function() route) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(text1, style: body4TextStyle.copyWith(color: textGrey2)),
      TextButton(
        onPressed: () => route(),
        style: const ButtonStyle(
          overlayColor: MaterialStatePropertyAll(Colors.transparent),
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

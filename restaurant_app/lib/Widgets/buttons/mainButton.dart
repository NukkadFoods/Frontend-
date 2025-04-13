import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

Widget mainButton(String buttonText, Color buttonTextColor, Function() route,
    {bool isLoading = false}) {
  return Center(
    child: SizedBox(
      height: 7.h,
      width: 90.w,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith(
            (states) => isLoading
                ? Colors.grey
                : primaryColor, // Change color based on isLoading
          ),
          elevation: MaterialStateProperty.resolveWith((states) => 2.0),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
              )
            : Text(buttonText.toUpperCase(),
                style: buttonTextStyle.copyWith(
                    color: buttonTextColor, fontWeight: FontWeight.w600)),
        onPressed: isLoading
            ? null
            : () => route(), // Disable the button if isLoading is true
      ),
    ),
  );
}

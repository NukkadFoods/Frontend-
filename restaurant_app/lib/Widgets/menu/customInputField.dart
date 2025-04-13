import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField(
      {super.key,
      required this.labelText,
      required this.controller,
      this.inputFormatter,
      this.keyboardType});

  final String labelText;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatter;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(7),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        inputFormatters: inputFormatter,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: textGrey2, width: 0.1.h),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: textGrey2, width: 0.1.h),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          labelText: labelText.toUpperCase(),
          labelStyle: body4TextStyle.copyWith(color: textGrey2),
        ),
      ),
    );
  }
}

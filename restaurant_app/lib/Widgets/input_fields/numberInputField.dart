import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

Widget numberInputField(String labelText, TextEditingController controller,
    Function(String) onInputChanged) {
  controller.addListener(() {
    onInputChanged(controller.text);
  });
  return Material(
    elevation: 3.0,
    borderRadius: BorderRadius.circular(7),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
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
      onChanged: (value) {
        onInputChanged(value);
      },
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/constants/colors.dart';

Widget textInputField(String labelText, TextEditingController controller,
    Function(String) onInputChanged, BuildContext context,
    {TextCapitalization? capitalization}) {
  controller.addListener(() {
    onInputChanged(controller.text);
  });
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  return Material(
    elevation: 3.0,
    borderRadius: BorderRadius.circular(7),
    child: TextField(
      controller: controller,
      style: TextStyle(color: isdarkmode ? textGrey2 : textBlack),
      keyboardType: TextInputType.text,
      textCapitalization: capitalization ?? TextCapitalization.none,
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/constants/colors.dart';

Widget phoneField(Function(String) onPhoneNumberChanged,BuildContext context,
    {String? initialPhoneNumber, required TextEditingController controller,bool isReadOnly = false}) {
   bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  String? phoneNumber;
  String countryCode =
      '+91'; // Default country code if initialPhoneNumber is null

  if (initialPhoneNumber != null) {
    // Check if initialPhoneNumber starts with '+'
    if (initialPhoneNumber.startsWith('+')) {
      phoneNumber = initialPhoneNumber;
    } else {
      // Assume initialPhoneNumber is provided without '+', prepend '+'
      phoneNumber = '+$initialPhoneNumber';
    }
  }

  if (initialPhoneNumber != null) {
    // Check if initialPhoneNumber starts with '+'
    if (initialPhoneNumber.startsWith('+')) {
      phoneNumber = initialPhoneNumber;
      // countryCode = initialPhoneNumber.substring(
      //     0, initialPhoneNumber.length - 10); // Extract country code
      // controller.text = initialPhoneNumber.substring(
      //     countryCode.length + 1); // Extract phone number without '+'
    } else {
      phoneNumber = '+$initialPhoneNumber';
      // Assume initialPhoneNumber is provided without '+', prepend '+'
      // countryCode = '+' +
      // initialPhoneNumber.substring(
      //     0, initialPhoneNumber.length - 10); // Extract country code
      // controller.text = initialPhoneNumber
      //     .substring(countryCode.length - 1); // Extract phone number
    }
  }
  controller.addListener(() {
    onPhoneNumberChanged(controller.text);
  });
  return Material(
    elevation: 3.0,
    borderRadius: BorderRadius.circular(7.0),
    child: IntlPhoneField(
      controller: controller,
      disableLengthCheck: true,
      keyboardType: TextInputType.phone,
      showDropdownIcon: false,
        readOnly: isReadOnly,
      flagsButtonPadding: EdgeInsets.symmetric(horizontal: 3.w),
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.0),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: 'Mobile'.toString().toUpperCase(),
        labelStyle: body4TextStyle.copyWith(color: textGrey2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: textGrey2, width: 0.1.h),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: BorderSide(color: textGrey2, width: 0.1.h),
        ),
      ),
      dropdownTextStyle: TextStyle(
        color: isdarkmode ? textGrey2 : textBlack,
        fontFamily: 'Poppins',
        fontSize: 13.sp,
      ),
      initialCountryCode: phoneNumber == null ? 'IN' : null,
      initialValue: phoneNumber ?? "",
      onCountryChanged: (country) {
        controller.text = '';
      },
      style: TextStyle(color: isdarkmode ? textGrey2 : textBlack),  
      onChanged: (phone) {
        onPhoneNumberChanged(phone.completeNumber);
      },
    ),
  );

  
}


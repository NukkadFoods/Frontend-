import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:user_app/widgets/constants/colors.dart';

class CustomPhoneField extends StatelessWidget {
  const CustomPhoneField(
      {super.key, required this.controller, this.label = 'MOBILE'});

  final CustomTextController controller;
  final String label;

  // String getPhoneNumberWithCountryCode() {
  //   return '+91${controller.text}';
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2, // Elevation value for shadow
      shadowColor: Colors.grey[400], // Shadow color
      borderRadius: BorderRadius.circular(7),
      child: Container(
        color: Colors.white,
        child: TextField(
          style: TextStyle(color: controller.textColor),
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            // LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly
          ],
          autocorrect: false,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: textGrey2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: textGrey2),
            ),
            labelText: label,
            labelStyle: const TextStyle(color: textGrey2),
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10,
                ),
                SvgPicture.asset(
                  'assets/images/indiaflag.svg', // Replace with your flag image asset path
                  width: 30, // Adjust width as needed
                  height: 30, // Adjust height as needed
                ),
                const SizedBox(
                    width: 8), // Adjust spacing between image and text
                const Text(
                  '+91',
                  style: TextStyle(
                      color: Colors.black87), // Adjust text color as needed
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextController extends TextEditingController {
  Color textColor = Colors.black;
}

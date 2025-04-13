import 'package:flutter/material.dart';


class CustomPhoneField extends StatelessWidget {
  const CustomPhoneField(
      {super.key, required this.controller, this.label = 'MOBILE'});

  final CustomTextController controller;
  final String label;

  String getPhoneNumberWithCountryCode() {
    return '+91${controller.text}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2, // Elevation value for shadow
      shadowColor: Colors.grey[400], // Shadow color
      borderRadius: BorderRadius.circular(7),
      child: Container(
        color: Colors.white,
        child: TextField(
          style: TextStyle(color: controller.textColor, fontSize: 16),
          controller: controller,
          keyboardType: TextInputType.number,
          // inputFormatters: [
          //   LengthLimitingTextInputFormatter(10),
          // ],
          autocorrect: false,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey),
            ),
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Image.asset(
                    'assets/images/indiaflag.png', // Replace with your flag image asset path
                    width: 30, // Adjust width as needed
                    height: 30, // Adjust height as needed
                  ),
                  SizedBox(width: 8), // Adjust spacing between image and text
                  Text(
                    '+91',
                    style: TextStyle(
                        fontSize: 16,
                        color: controller
                            .textColor), // Adjust text color as needed
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextController extends TextEditingController {
  CustomTextController({String? text})
      : super.fromValue(text == null
            ? TextEditingValue.empty
            : TextEditingValue(text: text));
  Color textColor = Colors.black;
}

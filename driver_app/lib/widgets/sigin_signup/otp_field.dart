import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.controller1,
    required this.controller2,
    required this.controller3,
    required this.controller4,
  });
  final TextEditingController controller1;
  final TextEditingController controller2;
  final TextEditingController controller3;
  final TextEditingController controller4;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildOTPField(controller1, context),
        buildOTPField(controller2, context),
        buildOTPField(controller3, context),
        buildOTPField(controller4, context)
      ],
    );
  }
}

Widget buildOTPField(TextEditingController controller, BuildContext context) {
  return Material(
    elevation: 2,
    shadowColor: Colors.grey[400],
    borderRadius: BorderRadius.circular(7),
    child: Container(
      width: 50,
      color: Colors.white,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    ),
  );
}

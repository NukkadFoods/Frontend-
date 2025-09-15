import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class PasswordField extends StatefulWidget {
  final String labelText;
  final void Function(String) onValueChanged; // Callback function
  const PasswordField(
      {Key? key, required this.labelText, required this.onValueChanged})
      : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isObscured = true;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3.0,
      borderRadius: BorderRadius.circular(7.0),
      child: TextField(
        controller: _controller,
        obscureText: _isObscured,
        onChanged: widget.onValueChanged,
        decoration: InputDecoration(
          labelText: widget.labelText.toUpperCase(),
          labelStyle: body4TextStyle.copyWith(color: textGrey2),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
            borderSide: BorderSide(
              color: textGrey2,
              width: 0.1.h,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
            borderSide: BorderSide(
              color: textGrey2,
              width: 0.1.h,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility : Icons.visibility_off,
              color: primaryColor,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when widget is disposed
    super.dispose();
  }
}

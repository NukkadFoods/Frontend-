import 'dart:convert';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/colors.dart';
import '../../utils/font-styles.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/full_width_green_button.dart';
import '../../widgets/common/transition_to_next_screen.dart';
import 'reset_password_success_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String deliveryBoyId;

  const ResetPasswordScreen({Key? key, required this.deliveryBoyId})
      : super(key: key);


  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
    });
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: colorRed,
        content: Text("Passwords do not match"),
      ));
      return;
    }

    String id = widget.deliveryBoyId; // Use the delivery boy ID passed to the screen
    String newPassword = _passwordController.text.trim();

    // final String baseUrl = dotenv.env['BASE_URL']!;
    final String baseUrl = AppStrings.baseURL;
    final response = await http.post(
      Uri.parse('$baseUrl/auth/updateDeliveryBoyById'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'updateData': {'password': newPassword},
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['executed']) {
        Navigator.of(context).push(
          transitionToNextScreen(ResetPasswordSuccessScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(responseData['message']),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Failed to reset password"),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_ios_new)),
        title: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
            ),
            Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: mediumLarge,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 60,
            ),
            CustomTextField(
              label: 'PASSWORD',
              controller: _passwordController,
              isObscured: _isPasswordObscured,
              icon: IconButton(
                icon: Icon(
                  _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                  color: colorGreen,
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CustomTextField(
              label: 'CONFIRM PASSWORD',
              controller: _confirmPasswordController,
              isObscured: _isConfirmPasswordObscured,
              icon: IconButton(
                icon: Icon(
                  _isConfirmPasswordObscured
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: colorGreen,
                ),
                onPressed: _toggleConfirmPasswordVisibility,
              ),
            ),
            SizedBox(
              height: 60,
            ),
            FullWidthGreenButton(
                label: 'RESET',
                onPressed: _resetPassword,
            )
          ],
        ),
      ),
    );
  }
}

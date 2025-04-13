import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/common/full_width_green_button.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
// import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityPinScreen extends StatelessWidget {
  const SecurityPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController pin = TextEditingController();
    var securitypin;

    Future<void> savePin(String pinumber) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('security_pin', pinumber);
      print(prefs.getString('security_pin'));
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: // Title
            Text(
          'Verification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity: 0.7,
                image: AssetImage('assets/images/otpbbg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),

                SizedBox(height: 16),

                Text(
                  'security Pin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Enter Your Security Pin',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                SizedBox(height: 40),

                // Pin input field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: PinCodeTextField(
                    controller: pin,
                    appContext: context,
                    length: 4,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 60,
                        fieldWidth: 60,
                        activeColor: colorBrightGreen,
                        inactiveColor: Colors.grey,
                        selectedColor: colorBrightGreen,
                        activeFillColor: Colors.transparent,
                        disabledColor: Colors.transparent,
                        inactiveFillColor: Colors.transparent,
                        selectedFillColor: Colors.transparent),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onCompleted: (v) {
                      print("Completed: $v");
                      securitypin = v;
                      savePin(securitypin);
                    },
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                ),

                SizedBox(height: 50),

                // Continue button
                SizedBox(
                    height: 40,
                    child: FullWidthGreenButton(
                        label: 'CONTINUE', onPressed: () {}))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

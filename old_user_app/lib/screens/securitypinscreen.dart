import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';

class SecurityPinScreen extends StatelessWidget {
  const SecurityPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController pin=TextEditingController();
    String securitypin;



    Future<void> savePin(String pinumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('security_pin', pinumber);
    print(prefs.getString(pinumber));
  }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title:      // Title
                const Text(
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                
                const SizedBox(height: 16),
                
                const Text(
                  'security Pin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                const Text(
                  'Enter Your Security Pin',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Pin input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: PinCodeTextField(
                    controller: pin,
                    appContext: context,
                    length: 4,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 60,
                      fieldWidth: 60,
                      activeColor: primaryColor,
                      inactiveColor: Colors.grey,
                      selectedColor: primaryColor,
                      activeFillColor: Colors.transparent,
                      disabledColor: Colors.transparent,
                      inactiveFillColor: Colors.transparent,
                      selectedFillColor: Colors.transparent
                      
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onCompleted: (v) {
                      print("Completed: $v");
                      securitypin=v;
                      savePin(securitypin);
                    },
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Continue button
               SizedBox
              
               (
                height:70,child: mainButton('CONTINUE', textWhite, (){}))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

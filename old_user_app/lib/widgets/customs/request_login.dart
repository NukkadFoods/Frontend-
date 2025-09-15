import 'package:flutter/material.dart';
import 'package:user_app/screens/loginScreen.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

Widget loginRequest(BuildContext context) {
  return SafeArea(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/introduction/newintro2.png'),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text("Please Login to access the full features of app",
              style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
        ),
        mainButton("Login", Colors.white, () {
          Navigator.of(context)
              .push(transitionToNextScreen(const LoginScreen(hideSkip: true)));
        })
      ],
    ),
  );
}

class RequestLoginScreen extends StatelessWidget {
  const RequestLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loginRequest(context),
    );
  }
}

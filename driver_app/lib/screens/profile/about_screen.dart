import 'package:driver_app/screens/profile/privacy_screen.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/profile/about_menu_item.dart';
import 'package:flutter/material.dart';

import '../../utils/font-styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: medium),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new)),
      ),
      body: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/otpbbg.png'),
                fit: BoxFit.cover,
                opacity: .5)),
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            // GestureDetector(
            //   onTap: () {},
            //   child: AboutMenuItem(
            //     label: 'Terms of Service',
            //   ),
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(transitionToNextScreen(PrivacyPolicyScreen()));
              },
              child: AboutMenuItem(
                label: 'Privacy Policy',
              ),
            )
          ],
        ),
      ),
    );
  }
}

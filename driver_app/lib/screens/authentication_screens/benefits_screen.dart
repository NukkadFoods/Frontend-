import 'package:driver_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../location_screens/location_screen.dart';

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LocationScreen()),
      );
    });
    return Scaffold(
      backgroundColor: colorGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Benefits For You',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
                child: SvgPicture.asset(
                  'assets/svgs/deal1.svg',
                  fit: BoxFit.fitWidth,
                ),
              )),
              for (int i = 2; i < 6; i++)
                Expanded(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
                  child: Image.asset(
                    'assets/images/deal$i.png',
                    fit: BoxFit.contain,
                  ),
                ))
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utils/font-styles.dart';

class Searching extends StatelessWidget {
  const Searching({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/animations/searching.json'),
        Text(
          'Searching for orders near you....',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: medium,
          ),
        ),
      ],
    );
  }
}
